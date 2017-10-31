#!/bin/bash

#echo "
#<div id="google_translate_element"></div><script type="text/javascript">
#function googleTranslateElementInit() {
#  new google.translate.TranslateElement({pageLanguage: 'zh-CN', layout: google.translate.TranslateElement.InlineLayout.SIMPLE, multilanguagePage: true}, 'google_translate_element');
#}
#</script><script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
#" >> ./public/index.html
cp -r ./public/* ~/Desktop/blog/newrepo/stevenlicmu.github.io/
cd ~/Desktop/blog/newrepo/stevenlicmu.github.io
git add .
git commit -m 'update'
git push
