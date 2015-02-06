fs = require 'fs'

process.chdir __dirname

assign = (tar, src)->
    for k, v of src
        tar[k] = v

setEnv = (rc, envArr)->
    rc.env ?= {}
    envArr.forEach (e)->
        rc.env[e] = yes

writeJSON = (fpath, data)->
    fs.writeFileSync fpath, JSON.stringify data, null, 4

ruleObjNode = {}
ruleObjBrowser = {}

strictObj = {}

parseRule = do ->
    rules = fs.readFileSync('eslintRule', 'utf8').split '\n'
    rules.forEach (line)->
        line = line.replace /\s/g, ''
        if not line or line[0] is '#' then return

        [rule, env] = line.split '#'

        if rule.indexOf('=') < 0
            rule = rule.replace ':', '='

        [k, v] = rule.split '='
        v = eval v

        env ?= ''
        env = env.split ','
        env.forEach (en)->
            switch en
                when 'browser' then ruleObjBrowser[k] = v
                when 'node' then ruleObjNode[k] = v
                when 'strict' then strictObj[k] = v
                else
                    ruleObjNode[k] = v
                    ruleObjBrowser[k] = v

nodeEslintRc = do ->
    env = ['node', 'mocha']
    rc = {}
    setEnv rc, env
    rc.rules = ruleObjNode
    writeJSON 'eslintrc-node.json', rc
    assign rc.rules, strictObj
    writeJSON 'eslintrc-node-strict.json', rc

browserEslintRc = do ->
    env = ['browser', 'amd', 'jquery']
    rc = {}
    setEnv rc, env
    rc.rules = ruleObjBrowser
    writeJSON 'eslintrc-browser.json', rc
    assign rc.rules, strictObj
    writeJSON 'eslintrc-browser-strict.json', rc
