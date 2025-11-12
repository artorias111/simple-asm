process quast {
    conda params.quast_conda

    publishDir "${params.outdir}/quast", mode: 'symlink'

    input:
    tuple path(genome_asm), val(asm_id) 

    output:
    path "${params.id}.${asm_id}.quast", emit: quast_results

    script:
    """
    quast -o ${params.id}.${asm_id}.quast \\
    -t ${params.nthreads} \\
    --x-for-Nx 90 \\
    --plots-format png \\
    --split-scaffolds \\
    ${genome_asm}
    """
}
