vcl 4.0;

import std;

include "/etc/varnish/fos/ban.vcl";
include "/etc/varnish/fos/debug.vcl";
include "/etc/varnish/fos/purge.vcl";
include "/etc/varnish/fos/refresh.vcl";
//include "/etc/varnish/fos/user_context.vcl";
//include "/etc/varnish/fos/user_context_url.vcl";
//include "/etc/varnish/fos/custom_ttl.vcl";

backend default {
    .host = "nginx";
    .port = "80";
}

acl invalidators {
    "localhost";
    "127.0.0.1";
    "nginx";
}

sub vcl_recv {
    # Pipe admin and dev env
    if (req.url ~ "^/(admin|app_dev|app_test)") {
        return (pipe);
    }

    # Pipe potential large files or streams
    if (req.url ~ "\.(mpeg|mpg|mp4|webm|ogg|flv|pdf|gz|rar|tar|bzip)(\?.*|)$" && req.url !~ "^/(app|index).php?") {
        unset req.http.Cookie;
        return (pipe);
    }

    # Unset cookie for media files
    if (req.url ~ "\.(jpeg|jpg|png|gif|svg|ico|swf|js|css|eot|ttf|woff|woff2|txt)(\?.*|)$" && req.url !~ "^/(app|index).php?") {
        unset req.http.Cookie;
        return (hash);
    }

    # Add a Surrogate-Capability header to announce ESI support.
    set req.http.Surrogate-Capability = "abc=ESI/1.0";

    # Make sure the client cant control our cache by ctrl+shift+R
    unset req.http.Cache-Control;

    # Set correct port
    if (req.http.X-Forwarded-Proto == "https" ) {
        set req.http.X-Forwarded-Port = "443";
    } else {
        set req.http.X-Forwarded-Port = "80";
    }

    call fos_purge_recv;
    call fos_refresh_recv;
    call fos_ban_recv;
    //call fos_user_context_recv;

    # Clean cookies, (hpprsess, referrals, target_after_test, redirect)
    set req.http.cookie = ";" + req.http.cookie;
    set req.http.cookie = regsuball(req.http.cookie, "; +", ";");
    set req.http.cookie = regsuball(req.http.cookie, ";(PHPSESSID|APP_REMEMBER_ME)=", "; \1=");
    set req.http.cookie = regsuball(req.http.cookie, ";[^ ][^;]*", "");
    set req.http.cookie = regsuball(req.http.cookie, "^[; ]+|[; ]+$", "");

    if (req.method == "GET" || req.method == "HEAD") {
        return (hash);
    }

    return (pass);
}

sub vcl_pipe {
    # http://www.varnish-cache.org/ticket/451
    # This forces every pipe request to be the first one.
    set bereq.http.connection = "close";
}

sub vcl_backend_response {
    call fos_ban_backend_response;
    //call fos_user_context_backend_response;
    //call fos_custom_ttl_backend_response;

    # Check for ESI acknowledgement and remove Surrogate-Control header
    if (beresp.http.Surrogate-Control ~ "ESI/1.0") {
        unset beresp.http.Surrogate-Control;
        set beresp.do_esi = true;
    }

    # GZip
    if (bereq.url ~ "\.(html|svg|js|css|eot|ttf|woff|woff2)(\?.*|)$" || beresp.http.Content-Type ~ "text") {
        set beresp.do_gzip = true;
    }

    # Clear cookie for media files
    if (bereq.url ~ "\.(jpeg|jpg|png|gif|svg|ico|swf|js|css|eot|ttf|woff|woff2|gz|rar|txt|bzip|flv|webm|ogg|mp4|mpeg|mpg)(\?.*|)$" &&
        bereq.url !~ "^/(app|index).php?"
    ) {
        unset beresp.http.set-cookie;
    }

    # Cache redirections but not 404
    if (beresp.ttl > 0s ) {
        if (beresp.status >= 300 && beresp.status <= 399) {
            set beresp.ttl = 10m;
        }
        if (beresp.status >= 399) {
            set beresp.ttl = 0s;
        }
    }

    # Clear cookie for 404 and co
    if (beresp.status >= 399) {
        unset beresp.http.set-cookie;
    }

    # Max ttl 24h
    if (beresp.ttl > 86400s) {
        set beresp.ttl = 86400s;
    }

    # Dont cache if set-cookie
    if (beresp.ttl > 0s && beresp.http.set-cookie) {
        set beresp.ttl = 0s ;
    }
}

sub vcl_deliver {
    call fos_ban_deliver;
    //call fos_user_context_deliver;
    call fos_debug_deliver;

    # Remove some headers: Varnish
    unset resp.http.Via;
    unset resp.http.X-Varnish;
    unset resp.http.Server;
    unset resp.http.X-Powered-By;
    unset resp.http.MS-Author-Via;
    unset resp.http.X-Cache-Tags;
}

sub vcl_backend_error {
    set beresp.http.Content-Type = "text/html; charset=utf-8";
    if (beresp.status == 503) { # Maintenance
        synthetic(std.fileread("/var/www/errors/503.html"));
    } else {                    # Error
        synthetic(std.fileread("/var/www/errors/500.html"));
    }
    return (deliver);
}
