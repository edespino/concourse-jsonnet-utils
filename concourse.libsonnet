{
  GitResource(name, repository, branch = 'master'):: {
    name: name,
    type: 'git',
    icon: 'git',
    source: {
      uri: repository,
      branch: branch
    },
  },

  DockerResource(name, repository, tag = 'latest', allow_insecure = false):: {
    name: name,
    type: 'docker-image',
    icon: 'docker',
    source: {
      repository: repository,
      tag: tag
    } + (
      if allow_insecure then { insecure_registries: [std.split(repository, '/')[0]]} else {}
    ),
  },

  Get(name, trigger = true, dependencies = []):: std.prune({
    get: name,
    trigger: trigger,
    passed: if std.isArray(dependencies) then dependencies else [dependencies]
  }),

  Group(name, jobs):: {
    name: name,
    jobs: jobs
  },

  Parallel(tasks):: {
    in_parallel: tasks
  },

  Job(name, serial = true, plan = []):: std.prune({
    name: name,
    serial: serial,
    plan: plan
  }),

  FileTask(path, platform = 'linux', inputs = [], caches = [], dir = null)::
    local toA(l) = if std.isArray(l) then inputs else [l];
  std.prune({
    platform: platform,
    inputs: [{ name: input } for input in toA(inputs)],
    caches: [{ path: cache } for cache in toA(caches)],
    run: {
      path: path,
      dir: if std.length(toA(inputs)) > 0 then toA(inputs)[0] else null
    }
  }),
}
