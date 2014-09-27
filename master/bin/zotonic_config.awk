#!/usr/bin/awk -f
/{(admin_)?password/ && ENVIRON["ADMINPASSWORD"] && defaults {
    x = index($2, "}")
    default = substr($2, 1, x-1)
    sub(default,"\""ENVIRON["ADMINPASSWORD"]"\"")
    print $0
    next
}
/.{dbhost,/ && ENVIRON["DB_PORT"] {
    split(ENVIRON["DB_PORT"], results, "\[/:\]")
    x = index($2, "}")
    default = substr($2, 1, x-1)
    sub(default, "\""results[4]"\"")
    print $0
    next
}
/.{dbport/ && ENVIRON["DB_PORT"] {
    split(ENVIRON["DB_PORT"], results, ":")
    x = index($2, "}")
    default = substr($2, 1, x-1)
    sub(default, results[3])
    print $0
    next
}
/.{dbschema,/ && ENVIRON["DBSCHEMA"] && defaults {
    x = index($2, "}")
    default = substr($2, 1, x-1)
    sub(default,"\""ENVIRON["DBSCHEMA"]"\"")
    print $0
    next
}
/.{dbuser,/ && ENVIRON["DBUSER"] && ENVIRON["DBPASSWORD"] && defaults {
    x = index($2, "}")
    default = substr($2, 1, x-1)
    sub(default,"\""ENVIRON["DBUSER"]"\"")
    print $0
    next
}
/.{dbpassword,/ && ENVIRON["DBUSER"] && ENVIRON["DBPASSWORD"] && defaults {
    # Had to hardcode the search string as it wasn't evaluated correctly
    # from a variable. Square brackets are causing trouble.
    sub("\\\[\\\]","\""ENVIRON["DBPASSWORD"]"\"")
    print $0
    next
}
/.{dbuser,/ && ENVIRON["DB_USERPASS"] && (!ENVIRON["DBUSER"] || !ENVIRON["DBPASSWORD"]) && defaults {
    split_result = split(ENVIRON["DB_USERPASS"], results, ":")
    x = index($2, "}")
    default = substr($2, 1, x-1)
    sub(default,"\""results[1]"\"")
    print $0
    next
}
/.{dbpassword,/ && ENVIRON["DB_USERPASS"] && (!ENVIRON["DBUSER"] || !ENVIRON["DBPASSWORD"]) && defaults {
    split_result = split(ENVIRON["DB_USERPASS"], results, ":")
    # Had to hardcode the search string as it wasn't evaluated correctly
    # from a variable. Square brackets are causing trouble.
    sub("\\\[\\\]","\""results[2]"\"")
    print $0
    next
}
{
    print
}
