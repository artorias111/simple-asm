process quast {
    conda params.quast_conda

    publishDir "${params.outdir}/quast", mode: 'symlink'

    input:
    path genome_asm

    output:
    path "${params.id}.quast", emit: quast_results

    script:
    """
    quast -o ${params.id}.quast -t ${params.nthreads} \\
    ${genome_asm}
    """
}
