
process INDEX {
    tag "$transcriptome.simpleName"
    conda 'salmon=1.10.2'
    
    input:
    path transcriptome 

    output:
    path 'index' 

    script:
    """
    salmon index --threads $task.cpus -t $transcriptome -i index
    """
}
