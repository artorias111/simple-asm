process run_merqury {
    conda params.merqury_env
    publishDir "${params.outdir}/merqury", mode: 'symlink'
    input:
    tuple val(reads), path(primary_asm), path(hap1_asm), path(hap2_asm), val(asm_id)

    output:
    path merqury_out

    script:
    """
    mkdir merqury_out
    cd merqury_out

    meryl count k=${params.merqury_ksize} \\
    threads=${params.nthreads} \\
    memory=${params.merqury_mem} \\
    output read-db.meryl \\
    ${reads}

    merqury.sh read-db.meryl ${primary_asm} ${asm_id}

    merqury.sh read-db.meryl ${hap1_asm} ${hap2_asm} ${asm_id}_hap
    """
}
