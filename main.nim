#!/usr/bin/env nim c -d:release -d:ssl --run main.nim

import httpclient
import json
import strformat
import net

# TODO: VS Code nim extension should support -d:ssl
# TODO: Private repos are being listed, even with a proper curl command.

const url = "https://api.github.com/users/prideout/repos?per_page=1000"

let ctx = net.newContext()
let client = newHttpClient(sslContext = ctx)
let responseString = client.getContent(url)
let dbJson = parseJson(responseString)

for repo in dbJson:
    var (name, desc) = (repo["name"].str, repo["description"].str)
    if desc == nil: desc = "NO DESCRIPTION"
    let private = repo["private"].getBool()
    let archived = repo["archived"].getBool()
    if not archived and not private:    
        echo fmt"{name:>21} ... {desc:<72}"

write(stdout, "\narchived: ")
for repo in dbJson:
    let name = repo["name"].str
    let archived = repo["archived"].getBool()
    if archived:    
        write(stdout, name & " ")
echo ""
