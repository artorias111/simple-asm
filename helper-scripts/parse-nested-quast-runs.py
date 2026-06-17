import argparse
from pathlib import Path

def main():
    # Set up command-line arguments
    parser = argparse.ArgumentParser(description="Parse nested QUAST report.tsv files into a summary table.")
    parser.add_argument(
        "search_dir", 
        nargs="?", 
        default=".", 
        help="The parent directory to search for QUAST reports (defaults to current directory '.')"
    )
    args = parser.parse_args()

    search_root = Path(args.search_dir)

    if not search_root.is_dir():
        print(f"Error: The directory '{search_root}' does not exist.")
        return

    # Target metrics mapping (QUAST TSV key -> Our Table Header)
    target_metrics = {
        "Total length": "Length",
        "# contigs": "Contigs",
        "N50": "N50",
        "L90": "L90"
    }
    
    results = []
    
    # Recursively find all report.tsv files starting from the provided search directory
    for report_path in search_root.rglob('report.tsv'):
        # Get the directory containing the report
        parent_dir = report_path.parent
        
        # Create a clean relative path for the table
        try:
            rel_path = str(parent_dir.relative_to(search_root))
            if rel_path == ".":
                rel_path = str(search_root)
        except ValueError:
            # Fallback just in case relative_to fails
            rel_path = str(parent_dir)
            
        data = {"Assembly": rel_path, "Length": "-", "Contigs": "-", "N50": "-", "L90": "-"}
        
        try:
            with open(report_path, 'r') as f:
                for line in f:
                    parts = line.strip().split('\t')
                    if len(parts) >= 2:
                        metric = parts[0].strip()
                        val = parts[1].strip()
                        
                        if metric in target_metrics:
                            data[target_metrics[metric]] = val
                            
            results.append(data)
        except Exception as e:
            print(f"Skipping {report_path} due to error: {e}")
            continue

    if not results:
        print(f"No QUAST report.tsv files found in '{search_root}' or its subdirectories.")
        return

    # Calculate dynamic width for the Assembly column for clean formatting
    max_asm_len = max([len(r['Assembly']) for r in results] + [35])
    
    # Build and print the table header
    header = f"{'Assembly (Relative Path)':<{max_asm_len}} | {'Length':<12} | {'Contigs':<10} | {'N50':<12} | {'L90':<8}"
    print(header)
    print("-" * len(header))
    
    # Sort alphabetically by assembly path and print rows
    for r in sorted(results, key=lambda x: x['Assembly']):
        print(f"{r['Assembly']:<{max_asm_len}} | {r['Length']:<12} | {r['Contigs']:<10} | {r['N50']:<12} | {r['L90']:<8}")

if __name__ == "__main__":
    main()
