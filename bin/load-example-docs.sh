#!/usr/bin/env bash

uri="http://${1:-127.0.0.1}:${2:-9200}"

curl -XDELETE $uri/test

curl -XPUT $uri/test

curl -XPUT $uri/test/crawler/_mapping -d '{
  "crawler" : {
    "properties": {
      "title": { "type": "string" },     
      "description":  { "type": "string" },
      "language" : { "type": "string", "index" : "not_analyzed" },
      "type" : { "type": "string", "index" : "not_analyzed" },
      "url" : { "type": "string", "index" : "not_analyzed" },
      "year" : { "type" : "integer" }
    }
  }
}'

curl -XPUT $uri/test/crawler/1 -d '{
  "title": "Google",
  "description": "Google Inc. is an American multinational corporation specializing in Internet-related services and products.",
  "language": "en",
  "type" : "Search Engines",
  "url" : "http://google.com",
  "year" : 1998
}'

curl -XPUT $uri/test/crawler/2 -d '{
  "title": "Facebook",
  "description": "Facebook is a social utility that connects people with friends and others who work, study and live around them.",
  "language": "en",
  "type" : "Social networks",
  "url" : "http://facebook.com",
  "year" : 2004
}'

curl -XPUT $uri/test/crawler/3 -d '{
  "title": "Youtube",
  "description": "YouTube is a video-sharing website on which users can upload, view and share videos.",
  "language": "en",
  "type" : "Online Video",
  "url" : "http://youtube.com",
  "year" : 2005
}'

curl -XPUT $uri/test/crawler/4 -d '{
  "title": "Yahoo",
  "description": "A new welcome to Yahoo. The new Yahoo experience makes it easier to discover the news and information that you care about most.",
  "language": "en",
  "type" : "Web Portals",
  "url" : "http://yahoo.com",
  "year" : 1994
}'

curl -XPUT $uri/test/crawler/5 -d '{
  "title": "百度",
  "description": "主要提供网页、音乐、图片、新闻搜索，同时有帖吧和WAP搜索功能",
  "language": "zh",
  "type" : "Search Engines",
  "url" : "http://baidu.com",
  "year" : 2000
}'

curl -XPUT $uri/test/crawler/6 -d '{
  "title": "Wikipedia",
  "description": "A free encyclopedia built collaboratively using wiki software. (Creative Commons Attribution-ShareAlike License).",
  "language": "en",
  "type" : "Dictionaries & Encyclopediast",
  "url" : "http://en.wikipedia.org",
  "year" : 2001
}'

curl -XPUT $uri/test/crawler/7 -d '{
  "title": "Google Deutschland",
  "description": "Suche im gesamten Web, in deutschsprachigen sowie in deutschen Sites. Zusätzlich kann gezielt nach Bildern, Videos und News gesucht werden.",
  "language": "de",
  "type" : "Search Engines",
  "url" : "http://google.de",
  "year" : 1998
}'

curl -XPUT $uri/test/crawler/8 -d '{
  "title": "Twitter",
  "description": "Instantly connect to what is most important to you. Follow your friends, experts, favorite celebrities, and breaking news.",
  "language": "en",
  "type" : "Social Networks",
  "url" : "http://twitter.com",
  "year" : 2006
}'

curl -XPUT $uri/test/crawler/9 -d '{
  "title": "WordPress",
  "description": "Start a WordPress blog or create a free website in seconds. Choose from over 200 free, customizable themes. Free support from awesome humans.",
  "language": "en",
  "type" : "Blogs",
  "url" : "http://wordpress.org",
  "year" : 2004
}'

curl -XPUT $uri/test/crawler/10 -d '{
  "title": "Blogspot",
  "description": "Free weblog publishing tool from Google, for sharing text, photos and video",
  "language": "en",
  "type" : "Blogs",
  "url" : "http://blogger.com",
  "year" : 1999
}'

curl -XPUT $uri/test/crawler/11 -d '{
  "title": "Яндекс",
  "description": "Поиск информации в интернете с учетом русской морфологии, возможность регионального уточнения.",
  "language": "ru",
  "type" : "Search Engines",
  "url" : "http://yandex.ru",
  "year" : 1997
}'

curl -XPUT $uri/test/crawler/12 -d '{
  "title": "Bing",
  "description": "Bing is a search engine that brings together the best of search and people in your social networks to help you spend less time searching and more time doing.",
  "language": "en",
  "type" : "Search Engines",
  "url" : "http://bing.com",
  "year" : 2009
}'

curl -XGET $uri/test/_refresh

