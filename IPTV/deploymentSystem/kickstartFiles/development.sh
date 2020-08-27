groupadd -g 500 developers
useradd -g developers yanfa
echo yf@tjiptv | passwd --stdin yanfa
setfacl -R -d -m g:developers:rwx /usr/local
setfacl -R  -m g:developers:rwx /usr/local
cat >>/etc/profile.d/for_developers.sh <<END
if [ "\`id -gn\`" = "developers" ];then
umask 002
fi
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
END
cat >>/etc/security/limits.conf <<END
@developers  soft  nofile  524288
@developers hard nofile   524288
END