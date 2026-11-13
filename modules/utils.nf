/*
 * Run a git command inside the pipeline's project directory.
 * Returns the trimmed output, or null if git fails or isn't available.
 */
def runGit(List args) {
    try {
        def proc = (['git', '-C', projectDir.toString()] + args).execute()
        def out  = proc.text.trim()
        proc.waitFor()
        return proc.exitValue() == 0 ? out : null
    } catch (Exception _e) {
        return null
    }
}

/*
 * Collect git information about the pipeline itself.
 */
def getPipelineGitInfo() {
    def info = [
        commit    : workflow.commitId,
        revision  : workflow.revision,
        repository: workflow.repository,
        dirty     : null
    ]

    // Fallback for local clones (nextflow run main.nf)
    if (!info.commit) {
        info.commit     = runGit(['rev-parse', 'HEAD'])
        info.revision   = runGit(['rev-parse', '--abbrev-ref', 'HEAD'])
        info.repository = runGit(['config', '--get', 'remote.origin.url'])
        def status      = runGit(['status', '--porcelain', '--untracked-files=no'])
        info.dirty      = (status != null) ? !status.isEmpty() : null
    }
    return info
}

def yamlQuote(v) {
    return v != null ? "'${v}'" : 'null'
}

/*
 * Build a YAML block in the same style as the per-process version files.
 */
def workflowVersionToYAML() {
    def git  = getPipelineGitInfo()
    def name = workflow.manifest.name ?: workflow.projectDir.name
    def dirty = git.dirty != null ? git.dirty.toString() : 'unknown'

    def lines = [
        'Workflow:',
        "    pipeline: ${yamlQuote(name)}",
        "    version: ${yamlQuote(workflow.manifest.version)}",
        "    commit: ${yamlQuote(git.commit)}",
        "    revision: ${yamlQuote(git.revision)}",
        "    repository: ${yamlQuote(git.repository)}",
        "    uncommitted_changes: ${dirty}",
        "    nextflow: ${yamlQuote(workflow.nextflow.version)}"
    ]
    return lines.join('\n') + '\n'
}