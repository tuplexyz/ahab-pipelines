#!/usr/bin/env nextflow 

/* 
 * Copyright (c) 2013-2023, Seqera Labs.
 * + Open-source modifications by Tuple, LLC.
 */

/*
 * Proof of concept of a RNAseq pipeline implemented with Nextflow
 * and modified to work with the ahab cloud system.
 *
 * Authors:
 * - Paolo Di Tommaso <paolo.ditommaso@gmail.com>
 * - Emilio Palumbo <emiliopalumbo@gmail.com>
 * - Evan Floden <evanfloden@gmail.com>
 * - Colby T. Ford <colby@tuple.xyz>
 */

/* 
 * enables modules 
 */
nextflow.enable.dsl = 2

/*
 * Default pipeline parameters. They can be overriden on the command line eg.
 * given `params.foo` specify on the run command line `--foo some_value`.
 */

// These data come from: https://github.com/nextflow-io/rnaseq-nf/tree/master/data/ggal

params.transcriptome = "$transcriptome"
params.reads = "$reads"
params.outdir = "$outdir"
params.multiqc = "$multiqc"

log.info """\
 R N A S E Q - N F   P I P E L I N E
 ===================================
 transcriptome: ${params.transcriptome}
 reads        : ${params.reads}
 outdir       : ${params.outdir}
 """

// import modules
include { RNASEQ } from './modules/rnaseq'
include { MULTIQC } from './modules/multiqc'

/* 
 * main script flow
 */
workflow {
  read_pairs_ch = channel.fromFilePairs( params.reads, checkIfExists: true ) 
  RNASEQ( params.transcriptome, read_pairs_ch )
  MULTIQC( RNASEQ.out, params.multiqc )
}

/* 
 * completion handler
 */
workflow.onComplete {
	log.info ( workflow.success ? "\nDone! Open the following report in your browser --> $params.outdir/multiqc_report.html\n" : "Oops .. something went wrong" )
}