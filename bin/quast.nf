process quast {
    conda params.quast_conda

    publishDir "${params.outdir}/quast", mode: 'symlink'

    input:
    tuple path(genome_asm), val(asm_id) 

    output:
    path "${params.id}.${asm_id}.quast", emit: quast_results

    script:
    """
    quast -o ${params.id}.${asm_id}.quast -t ${params.nthreads} \\
    --k-mer-stats --x-for-Nx 90 \\
    --report-all-metrics ${genome_asm}
    """
}
