#!/usr/bin/env nim c -d:release -d:ssl --run main.nim

import httpclient
import json
import strformat

# TODO: VS Code nim extension should support -d:ssl

let client = newHttpClient()

const showPrivate = false

when showPrivate:
    const url = "https://api.github.com/user/repos?per_page=100"
    encodedAuth = b64encode("username:password").decode("ascii")
    client.headers = newHttpHeaders({
        "Authorization": "Basic {encodedAuth}"
    })
else:
    const url = "https://api.github.com/users/prideout/repos?per_page=100"

let responseString = client.getContent(url)
let dbJson = parseJson(responseString)

for repo in dbJson:
    var (name, desc) = (repo["name"].str, repo["description"].str)
    if desc == nil: desc = "NO DESCRIPTION"
    let private = repo["private"].getBool()
    let archived = repo["archived"].getBool()
    let fork = repo["fork"].getBool()
    if not archived and not private and not fork:
        echo fmt"{name:>21} ... {desc:<72}"

when showPrivate:
    echo "\nprivate: "
    for repo in dbJson:
        var (name, desc) = (repo["name"].str, repo["description"].str)
        if desc == nil: desc = "NO DESCRIPTION"
        let private = repo["private"].getBool()
        let archived = repo["archived"].getBool()
        if not archived and private:
            echo fmt"{name:>21} ... {desc:<72}"

write(stdout, "\narchived: ")
for repo in dbJson:
    let name = repo["name"].str
    let archived = repo["archived"].getBool()
    if archived:    
        write(stdout, name & " ")
echo ""
