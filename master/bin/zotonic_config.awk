#!/usr/bin/awk -f
/{(admin_)?password/ && ENVIRON["ADMINPASSWORD"] && defaults {
    sub($2,"\""ENVIRON["ADMINPASSWORD"]"\"},")
    print $0
    next
}
/.{dbhost,/ && ENVIRON["DBHOST"] {
    sub($2,"\""ENVIRON["DBHOST"]"\"},")
    print $0
    next
}
/.{dbport/ && ENVIRON["DB_PORT"] {
    split(ENVIRON["DB_PORT"], results, ":")
    sub($2, results[3]"},")
    print $0
    next
}
/.{dbschema,/ && ENVIRON["DBSCHEMA"] && defaults {
    sub($2,"\""ENVIRON["DBSCHEMA"]"\"},")
    print $0
    next
}
/.{dbuser,/ && ENVIRON["DBUSER"] && ENVIRON["DBPASSWORD"] && defaults {
    print "   " $1 "\""ENVIRON["DBUSER"]"\"},"
    next
}
/.{dbpassword,/ && ENVIRON["DBUSER"] && ENVIRON["DBPASSWORD"] && defaults {
    print "   " $1 "\""ENVIRON["DBPASSWORD"]"\"},"
    next
}
/.{dbuser,/ && ENVIRON["DB_USERPASS"] && (!ENVIRON["DBUSER"] || !ENVIRON["DBPASSWORD"]) && defaults {
    split_result = split(ENVIRON["DB_USERPASS"], results, ":")
    sub($2,"\""results[1]"\"},")
    print $0
    next
}
/.{dbpassword,/ && ENVIRON["DB_USERPASS"] && (!ENVIRON["DBUSER"] || !ENVIRON["DBPASSWORD"]) && defaults {
    split_result = split(ENVIRON["DB_USERPASS"], results, ":")
    print "   " $1 "\""results[2]"\"},"
    next
}
{
    print
}
