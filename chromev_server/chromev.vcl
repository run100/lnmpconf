backend chromev {              #定义后端服务器名
   .host = "10.251.244.169";    #定义后端服务器IP
   .port = "80";      #定义后端服务器
   .connect_timeout = 1s; # Wait a maximum of 1s for backend connection (Apache, Nginx, etc...)
   .first_byte_timeout = 5s; # Wait a maximum of 5s for the first byte to come from your backend
   .between_bytes_timeout = 2s; # Wait a maximum of 2s between each bytes sent
}

#定义访问控制列表,充许那些IP清除varnish 缓存
acl local {
   "localhost";
   "127.0.0.1";
}


#host请求针对那个后端服务器
sub vcl_recv {
   if (req.http.host ~ "^(.*.)?(chromev|ddtao).(com|cc)$") {  #泛域名的写法"^(.*.)?kerry.com$"
	  set req.backend = chromev;
   }
   else {
	  error 404 "Unknown HostName!"; #如果都不匹配，返回404错误
   } 
#不充许非访问控制列表的IP进行varnish缓存清除
   if(req.request == "PURGE") {
	  if (!client.ip ~ local) {
		 error 405 "Not Allowed.";
		 return (lookup);
	  }
   }
#清除url中有jpg|png|gif等文件的cookie
   if (req.request == "GET" && req.url ~ "\.(jpg|png|gif|swf|jpeg|ico)$") {
	  unset req.http.cookie;
   }
#取消服务器上images目录下所有文件的cookie
   if (req.url ~ "^/images") {
	  unset req.http.cookie;
   }
#判断req.http.X-Forwarded-For,如果前端有多重反向代理,这样可以获取客户端IP地址。
   if (req.http.x-forwarded-for) {
	  set req.http.X-Forwarded-For =
		 req.http.X-Forwarded-For ", " client.ip;
   }
   else {
	  set req.http.X-Forwarded-For = client.ip;
   }
   if (req.request != "GET" &&
		 req.request != "HEAD" &&
		 req.request != "PUT" &&
		 req.request != "POST" &&
		 req.request != "TRACE" &&
		 req.request != "OPTIONS" &&
		 req.request != "DELETE") {
	  return (pipe);
   }
#针对请求和url地址判断，是否在varnish缓存里查找
   if (req.request != "GET" && req.request != "HEAD") {
	  return (pass);
   } ## 对非GET|HEAD请求的直接转发给后端服务器
   if (req.http.Authorization || req.http.Cookie) {
	  return (pass);
   }
   if (req.request == "GET" && req.url ~ "\.(php)($|\?)") {
	  return (pass);
   } #对GET请求，且url里以.php和.php?结尾的，直接转发给后端服务器
   return (lookup);
}  #除了以上的访问以外，都在varnish缓存里查找


sub vcl_pipe {
   return (pipe);
}
sub vcl_pass {
   return (pass);
}

sub vcl_hash {
   set req.hash += req.url;
   if (req.http.host) {
	  set req.hash += req.http.host;
   } else {
	  set req.hash += server.ip;
   }
   return (hash);
}


sub vcl_hit {
   if (!obj.cacheable) {
	  return (pass);
   }
   if (req.request == "PURGE") {
	  set obj.ttl = 0s;
	  error 200 "Purged.";
   }
   return (deliver);
}

sub vcl_miss {
   return (fetch);
}

sub vcl_fetch {
   if (!beresp.cacheable) {
	  return (pass);
   }
   if (beresp.http.Set-Cookie) {
	  return (pass);
   }
#WEB服务器指明不缓存的内容，varnish服务器不缓存
   if (beresp.http.Pragma ~ "no-cache" ||
		 beresp.http.Cache-Control ~ "no-cache" ||
		 beresp.http.Cache-Control ~ "private") {
	  return (pass);
   }
#对.txt .js .shtml结尾的URL缓存时间设置1小时，对其他的URL缓存时间设置为10天
   if (req.request == "GET" && req.url ~ "\.(txt|js|css|shtml|html|htm)$") {
	  set beresp.ttl = 3600s;
   }
   else {
	  set beresp.ttl = 10d;
   }
   return (deliver);
}

#添加在页面head头信息中查看缓存命中情况
sub vcl_deliver {
   set resp.http.x-hits = obj.hits ;
   if (obj.hits > 0) {
	  set resp.http.X-Cache = "HIT cqtel-bbs";
   }
   else {
	  set resp.http.X-Cache = "MISS cqtel-bbs";
   }
}


sub vcl_error {
   set obj.http.Content-Type = "text/html; charset=utf-8";
   synthetic {"
	  <?xml version="1.0" encoding="utf-8"?>
		 <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
		 <html>
		 <head>
		 <title>"} obj.status " " obj.response {"</title>
		 </head>
		 <body>
		 <h1>Error "} obj.status " " obj.response {"</h1>
		 <p>"} obj.response {"</p>
		 <h3>Guru Meditation:</h3>
		 <p>XID: "} req.xid {"</p>
		 <hr>
		 <address>
		 <a href="http://chromev.com/">chromev cache server</a>
		 </address>
		 </body>
		 </html>
		 "};
   return (deliver);
}
