process busco {
    conda params.busco_conda
    publishDir "${params.outdir}/busco", mode: 'symlink'

    input:
    tuple path(genome_asm), val(asm_id)

    output:
    path "${params.id}.${asm_id}.busco", emit: busco_results

    script:
    """
    busco -o ${params.id}.${asm_id}.busco \\
    -i ${genome_asm} \\
    -m geno \\
    -l ${params.busco_lineage} \\
    --download_path ${params.busco_db_path} \\
    -c ${params.nthreads} \\
    --offline
    """
}

