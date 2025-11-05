process busco {
    conda params.busco_conda
    publishDir "${params.outdir}/busco", mode: 'symlink'

    input:
    path genome_asm

    output:
    path "${params.id}.busco", emit: busco_results

    script:
    """
    busco -o ${params.id}.busco \\
    -i ${genome_asm} \\
    -m geno \\
    -l ${params.busco_lineage} \\
    --download_path ${params.busco_db_path} \\
    -c ${params.nthreads} \\
    --offline
    """
}

