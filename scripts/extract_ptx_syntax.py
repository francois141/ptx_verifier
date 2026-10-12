#!/usr/bin/env python3
"""Extract PTX instruction syntax and example blocks from the PTX ISA PDF.

Code blocks are gray rectangles (#f2f2f2, non_stroking_color=0.95) between given headers.
"""

import argparse
import re
import sys
import pdfplumber

START_PAGE = 131  # 1-indexed, inclusive
END_PAGE = 781    # 1-indexed, exclusive

GRAY_COLOR = 0.95  # #f2f2f2 as grayscale


def clean_block(text: str) -> str:
    """Remove noise from extracted blocks."""
    # Remove line continuation markers: join lines ending with hyphen followed by
    # newline and ,→ (visual line wrap indicator in the PDF)
    text = re.sub(r'-\s*\n,→', '-', text)
    text = re.sub(r'￿\s*\n,→', '', text)  # Also handle ￿ variant
    text = re.sub(r'\n,→', '', text)  # Catch any remaining continuation markers
    
    # Fix Unicode division slash (U+2215) being used instead of regular slash
    text = text.replace('∕', '/')
    
    # Remove trailing empty lines
    lines = text.split('\n')
    while lines and not lines[-1].strip():
        lines.pop()
    
    return '\n'.join(lines)


def find_header_positions(page, header_texts: list[str]) -> list[tuple[str, float]]:
    """Find vertical positions (top) of header texts on the page.

    Returns list of (header_text, position) tuples sorted by position."""
    words = page.extract_words()
    results = []
    for word in words:
        if word['text'] in header_texts:
            results.append((word['text'], word['top']))
    return sorted(results, key=lambda x: x[1])


def get_gray_rects(page) -> list[dict]:
    """Get all gray background rectangles on the page, sorted by vertical position."""
    rects = [r for r in page.rects if r.get('non_stroking_color') == GRAY_COLOR]
    return sorted(rects, key=lambda r: r['top'])


def extract_blocks_between_headers(
    pdf_path: str,
    start_page: int,
    end_page: int,
    start_headers: list[str],
    end_headers: list[str],
    show_progress: bool = True,
    block_type: str = "block"
) -> list[dict]:
    """Extract gray background blocks between `start_headers` and `end_headers`.

    Pages are 1-indexed, `end_page` exclusive; returns dicts with 'page' and 'content' keys."""
    results = []
    total_pages = end_page - start_page
    all_headers = start_headers + end_headers
    
    # State tracking across pages
    in_section = False
    current_page = None
    current_texts = []
    
    def save_current_block():
        nonlocal current_texts
        if current_texts:
            combined = '\n'.join(current_texts)
            cleaned = clean_block(combined)
            if cleaned:
                results.append({
                    'page': current_page,
                    'content': cleaned
                })
        current_texts = []
    
    with pdfplumber.open(pdf_path) as pdf:
        for i, page_num in enumerate(range(start_page - 1, end_page - 1)):
            if show_progress and (i % 50 == 0 or i == total_pages - 1):
                progress = (i + 1) / total_pages
                bar_width = 40
                filled = int(bar_width * progress)
                bar = '█' * filled + '░' * (bar_width - filled)
                sys.stdout.write(f'\rProcessing: [{bar}] {i+1}/{total_pages} pages ({len(results)} {block_type}s found)')
                sys.stdout.flush()
            
            page = pdf.pages[page_num]
            display_page = page_num + 1  # 1-indexed for output
            
            header_positions = find_header_positions(page, all_headers)
            gray_rects = get_gray_rects(page)
            
            # Process gray rects based on current state and header events
            rect_idx = 0
            event_idx = 0
            
            while rect_idx < len(gray_rects):
                rect = gray_rects[rect_idx]
                rect_top = rect['top']
                
                # Process any headers that come before this rect
                while event_idx < len(header_positions) and header_positions[event_idx][1] < rect_top:
                    header_text, _ = header_positions[event_idx]
                    if header_text in start_headers:
                        save_current_block()
                        in_section = True
                        current_page = display_page
                    elif header_text in end_headers:
                        save_current_block()
                        in_section = False
                    event_idx += 1
                
                # If we're in a target section, capture this rect's text
                if in_section:
                    bbox = (rect['x0'], rect['top'], rect['x1'], rect['bottom'])
                    try:
                        cropped = page.within_bbox(bbox)
                        text = cropped.extract_text()
                        if text:
                            current_texts.append(text)
                    except Exception:
                        pass  # Skip rects that cause extraction issues
                
                rect_idx += 1
            
            # Process any remaining headers after all rects
            while event_idx < len(header_positions):
                header_text, _ = header_positions[event_idx]
                if header_text in start_headers:
                    save_current_block()
                    in_section = True
                    current_page = display_page
                elif header_text in end_headers:
                    save_current_block()
                    in_section = False
                event_idx += 1
        
        # Handle any remaining block at end of document
        save_current_block()
    
    if show_progress:
        sys.stdout.write('\n')
    
    return results


def extract_syntax_blocks(pdf_path: str, start_page: int, end_page: int, show_progress: bool = True) -> list[dict]:
    """Extract syntax blocks (between 'Syntax' and 'Description' headers)."""
    blocks = extract_blocks_between_headers(
        pdf_path, start_page, end_page,
        start_headers=['Syntax'],
        end_headers=['Description'],
        show_progress=show_progress,
        block_type="syntax block"
    )
    # Rename 'content' to 'syntax' for backwards compatibility
    return [{'page': b['page'], 'syntax': b['content']} for b in blocks]


def extract_example_blocks(pdf_path: str, start_page: int, end_page: int, show_progress: bool = True) -> list[dict]:
    """Extract example blocks (between 'Example'/'Examples' and next section headers)."""
    blocks = extract_blocks_between_headers(
        pdf_path, start_page, end_page,
        start_headers=['Example', 'Examples'],
        end_headers=['Syntax', 'Description', 'Example', 'Examples'],
        show_progress=show_progress,
        block_type="example"
    )
    return [{'page': b['page'], 'example': b['content']} for b in blocks]


def write_blocks(blocks: list[dict], output_path: str, content_key: str, block_type: str):
    """Write extracted blocks to a file."""
    with open(output_path, 'w') as f:
        for i, block in enumerate(blocks):
            f.write(f"{'='*60}\n")
            f.write(f"{block_type} {i+1} (Page {block['page']})\n")
            f.write(f"{'='*60}\n")
            f.write(block[content_key])
            f.write("\n\n")
    print(f"Output written to {output_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Extract PTX instruction syntax and example blocks from the PTX ISA PDF."
    )
    parser.add_argument(
        "input_pdf",
        help="Path to the PTX ISA PDF file"
    )
    parser.add_argument(
        "-o", "--output",
        default="ptx_syntax_blocks.txt",
        help="Output file path (default: ptx_syntax_blocks.txt)"
    )
    parser.add_argument(
        "-t", "--type",
        choices=["syntax", "examples"],
        default="syntax",
        help="Type of blocks to extract (default: syntax)"
    )
    args = parser.parse_args()
    
    print(f"Extracting {args.type} blocks from pages {START_PAGE}-{END_PAGE-1}...")
    
    if args.type == "syntax":
        blocks = extract_syntax_blocks(args.input_pdf, START_PAGE, END_PAGE)
        content_key = "syntax"
        block_type = "Syntax"
    else:
        blocks = extract_example_blocks(args.input_pdf, START_PAGE, END_PAGE)
        content_key = "example"
        block_type = "Example"
    
    print(f"Found {len(blocks)} {args.type} blocks")
    write_blocks(blocks, args.output, content_key, block_type)


if __name__ == "__main__":
    main()
