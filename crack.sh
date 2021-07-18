#!/bin/bash
set -e
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
trap "echo -e '\nBye~The scipt by Sebastion(https://blog.linux-code.com)'" EXIT
NULL="/dev/null"
RESULT="result.$(date +%F-%H:%M)"
[ $(id -u) != '0' ] && echo "Must be root or use 'sudo' to exec the scipt" && exit 1
: start

function SYS_CHECK() {
   RELEASE="/etc/redhat-release"
   [ -e $RELEASE ] && { system=$(awk '{print $1}' < $RELEASE);ver=$(grep -Po "[\d+\.]+[\d+]" $RELEASE); } || \
   system=$(awk 'NR==1{print $1}' /etc/issue)

   [ $system != "Kali" -a $system != "Red" -a $system != "CentOS" ] && ver=$(grep -Po "[[:blank:]*\d]+.?(\d+)"< <(cat /etc/issue))

  if [[ $system =~ [Cc]ent[Oo][Ss] || $system =~ ^[Rr]ed ]];  then  

      YUM_PATH="/etc/yum.repos.d";Install="yum install";code=1

  elif [[ $system =~ [Kk]ali || $system =~ [Dd]ebian || $system =~ [Uu]buntu || $system =~ [Mm]int ]];  then 

      YUM_PATH="/etc/apt" && Install="apt-get install";code=2
  else 
       echo -e "[\033[31m-\033[0m]Sorry,the script does not support the system" && exit 2
  fi
  }
OTHER_PROTOCOL=(
  $(for i in $(echo 'asterisk cvs cisco-enable firebird ftp ftps icq imap irc ldap2 nntp mssql
    mysql oracle-sid pcanywhere pcnfs pop3 rdp postgres radmin2  rexec rlogin rpcap rtsp 
    sip smb smtp smtp-enum socks5 ssh sshkey svn teamspeak vnc xmpp');do 
  echo "$i";done|tr ' ' '\n')
)
function NMAP_AREA() {
        nmap -sP -Pn -n $IP_AERA|tee -a scan.txt
        nmapfile=nmap-${RESULT}.txt
        grep -B 1 "up" scan.txt|grep -Po "(?m)\s*[\w+\.]+\.\d+" &>$nmapfile
        sed -i '$d;1iOnline  Host:' $nmapfile
        shred -f -u -z scan.txt &>/dev/null
        echo && echo -e "[\033[32m\033[5m+\033[0m]All host scan finished,Up host is saved in '$(pwd)/${nmapfile}'"
}
function DPKG() {
   function STATUS {
      if [ $? != 0 ];then
          echo -e "[\033[31m-\033[0m]The system not install $1"
          sleep 0.5
          echo -e "[\033[32m+\033[0m]Installing $1,please wait a few seconds..."
          { yes|$Install $1 && status=0 || status=1; } &>$NULL
          
          while true;do
            if [ $status != 0 ];then 
                echo "[\033[31m-\033[0m]Sorry,can't install $1,please manual install it" && exit 1
            else
                echo -e "[\033[32m+\033[0m]${1} install done" && break
            fi
          done
      fi
     }
   
     if [ $code == 1 ];then 
        rpm -qa|grep $1 &>$NULL
        STATUS $1
     else 
        dpkg --list $1 >$NULL 2>&1
        STATUS $1
     fi 
  } ##DPKG END

function HYDRA_TARGET_LOCK() {
  if [ -f $hd_target -a -s $hd_target ]; then
      while true;do
         PORT_ENTER
         if [[ $PORT_STATU =~ ^no$ ]]; then

              now_file="$RESULT"
              eval hydra -L $user -P $password -V -M $hd_target $PT -o $now_file
              END now_file

         elif [[ $PORT_STATU =~ ^yes$ ]]; then

              now_file="$RESULT"
              eval hydra -L $user -P $password -V -s $PORT_LOCK -M $hd_target $PT -o $now_file
              END now_file
                                
         else
              NEXT Port && continue
         fi && exit
      done 
  elif [[ $hd_target =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
      while true;do
          PORT_ENTER
          if [[ $PORT_STATU =~ ^no$ ]]; then

              now_file="$RESULT"
              eval hydra -L $user -P $password -V $PT://$hd_target -o $now_file
              END now_file

          elif [[ $PORT_STATU =~ ^yes$ ]]; then

              now_file=$RESULT
              eval hydra -L $user -P $password -V -s $PORT_LOCK $PT://$hd_target -o $now_file
              END now_file

          else

              NEXT Port && continue

          fi && exit

      done 
  else
      NEXT Target && continue
  fi && exit
                     }

 function HYDRA_TARGET_LOCK_TWO() {
  if [ -f $hd_target -a -s $hd_target ]; then
      while true; do
          PORT_ENTER                          
          if [[ $PORT_STATU =~ ^no$ ]]; then

              now_file=$RESULT
              eval hydra -L $user -P $password -V -t 16 -M $hd_target $PT -o $now_file
              END now_file

          elif [[ $PORT_STATU =~ ^yes$ ]]; then

              now_file=$RESULT
              eval hydra -L $user -P $password -V -s $PORT_LOCK -t 16 -M $hd_target $PT -o $now_file
              END now_file

          else
              NEXT Port && continue
              fi && exit
          done
  elif [[ $hd_target =~ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+ ]]; then
      while true; do
          PORT_ENTER
          if [[ $PORT_STATU =~ ^no$ ]]; then

              now_file=$RESULT
              eval hydra -l $user -P $password -t 16 -V $hd_target $PT -o $now_file
              END now_file

          elif [[ $PORT_STATU =~ ^yes$ ]]; then

              now_file=$RESULT
              eval hydra -l $user -P $password -t 16 -V -s $PORT_LOCK $hd_target $PT -o $now_file
              END now_file

          else
              NEXT Port && continue
              fi && exit
          done
  else 
      NEXT Target&& continue
  fi && exit 
                                } 

function TARGET_LOCK() {
  while true; do
        read -p "Input target IP or URL:" target;
        ping -c 1 $target &>$NULL;
        if [ $? != 0 ]; then
            echo -e "[\033[31m-\033[0m]Sorry,$target does not exist or is not connected，please input again" && continue
        else
            tar_IP=$(ping -c 1 $target|grep -Po '(?m)(?<=\()(\d+\.)+\d+(?=\))'|awk 'NR==1{print}')  && break
        fi;
  done
}
function VALUE_ENTER() {
  [ ! -n "${!1}" ] && NEXT
}

function PORT_ENTER() {
      local hd_port
      if [ $default_port != none ]; then
          read -p "输入端口(默认 ${default_port}):" hd_port
      else
          read -p "输入端口:" hd_port
      fi
      PORT_LOCK=${hd_port}
      [[ ${PORT_LOCK} =~ ^[1-9] ]] && PORT_STATU=$(awk 'BEGIN{if(0<$PORT_LOCK&&$PORT_LOCK<65537);print "yes"}') || PORT_STATU=no
  }

function END() {
echo
ARR=${!1}
echo -e "[\033[32m\033[5m+\033[0m]All task is finished,the results is saved in '$ARR'"
}

function PROTOCOL() {
   PT="$1"
   case ${1} in
      ssh)
              default_port=22
              ;;
      rdp)
              default_port=3389
              ;;
      ftp)
              default_port=21
              ;;
      telnet)
              default_port=23
              ;;
      mysql)
              default_port=3306
              ;;
      smb)
              default_port=445
              ;;
      mssql)
              default_port=1433
              ;;
      *)      
              default_port=none
              ;;
  esac
   START && exit
}

 function NEXT() {
    echo -e "[\033[31m-\033[0m]Sorry,${1} input erorr,please input again"
 }

 function START() {
  while true; do
    read -p "输入用户名字典文件(自行创建)或单个用户名:" user
        VALUE_ENTER user && continue
        if [ -f $user -a -s $user ]; then
            read -p "输入密码字典文件(自行创建):" password
            VALUE_ENTER password && continue
            if [ -f $password -a -s $password ]; then
                while true; do
                    read -p "输入批量目标字典文件(自行创建，一行一个)或单个IP:" hd_target
                    VALUE_ENTER hd_target && continue
                    HYDRA_TARGET_LOCK
                done
            else
                 NEXT "Password file" && continue
            fi && break       
        elif [ -n $user -a ! -f $user ]; then
            while true; do
                read -p "输入密码字典文件(自行创建):" password
                VALUE_ENTER password && continue
                
                if [ -f $password -a -s $password ]; then
                    while true; do
                        read -p "输入批量目标字典文件(自行创建，一行一个)或单个IP:" hd_target
                        VALUE_ENTER hd_target && continue
                        HYDRA_TARGET_LOCK_TWO
                    done 
                else
                    NEXT 'Password file' && continue
                fi && exit
            done
        else
             NEXT 'User or file' 
        fi && exit
    done
 }

#########start########
clear
echo "#############################################################"
echo "# Hacking Automation Script                                 #"
echo "# Intro : https://blog.linux-code.com                       #"
echo "# Author: RokasUrbelis(Sebastion)                           #"
echo "# Email : Rokas.Yang@gmail.com                              #"
echo "# QQ    : 1798996632                                        #"
echo "#############################################################"
sleep 0.5
echo -e "[\033[32m+\033[0m]The script By RokasUrbelis(Sebastion)"
echo -e "[\033[32m+\033[0m]Article address:https://blog.linux-code.com/articles/thread-659.html"
sleep 0.5
SYS_CHECK
echo "################选择你要执行的选项################"
echo -e "\033[33m1.nmap端口扫描\033[0m"
echo -e "\033[33m2.hydra暴力破解\033[0m"
while true; do
read -p "Input Option:"
case ${REPLY} in
  1)
      DPKG nmap && {

        echo -e "\033[33m1.服务及端口探测\033[0m";
        echo -e "\033[33m2.操作系统识别\033[0m";
        echo -e "\033[33m3.指定端口或端口范围扫描\033[0m";
        echo -e "\033[33m4.漏洞扫描\033[0m";
        echo -e "\033[33m5.WHOIS查询\033[0m";
        echo -e "\033[33m6.探测指定网段所有在线主机\033[0m";
        echo -e "\033[33m7.主机批量扫描\033[0m";
        echo -e "\033[33m8.调用其它脚本扫描\033[0m";
        while true; do
          read -p "Input option:" Option;
          case $Option in
             1)
                  TARGET_LOCK;
                  nmap -sV -n -Pn $target && break;;
             2)
                  TARGET_LOCK;
                  nmap -O --osscan-guess -n -Pn --reason $tar_IP && break;;
             3)
                  TARGET_LOCK;
                  while true; do
                  read -p "Input port(e.g:22,23 1-65535 80):" port;
                  if [[ $port =~ [[:blank:]]*[0-9]+[,-]?[0-9]* ]]; then
                     nmap -n -sS -Pn -p $port $tar_IP && break;
                  else
                     echo -e "[\033[31m-\033[0m]Sorry,port input erorr,please input again" && continue
                  fi;
                  done && break;;
             4)
                  TARGET_LOCK;
                  nmap --script vuln -v $target && break;;
             5)
                  TARGET_LOCK;
                  if ls /usr/bin/../share/nmap/scripts|grep -i whois-domain &>$NULL
                  then
                       nmap --script whois-domain -n -Pn $target
                  else
                       echo -e "\033[31m-\033[0m]Sorry,the nmap version is too old,please update it" && exit
                  fi && break;; 
             6)
                  while :; do
                      read -p "是否扫描当前网段?(Y/N):"
                      case $REPLY in
                          Y|y)
                              while true; do
                                    read -p "输入网卡名(default eth0):" NETCARD
                                    [[ "${NETCARD}" == "" ]] && NETCARD=eth0
                                    ALL_NET=(
                                              $(for i in $(ip addr> >(grep -Po '(?<=[[:blank:]]).*(?=:[[:blank:]]\<)'))
                                              do
                                                  echo $i
                                              done)
                                            ) ###遍历网卡
                                    if { for i in ${ALL_NET[@]};do echo $i;done|grep $NETCARD; } &>/dev/null; then  ##验证网卡是否存在
                                       IP_AERA=$(grep -Po '[\d+\.]+\.\d+\/\d+'< <(ip a s> >(grep $NETCARD)))   ##取出网卡网段
                                       if [ ! -n $IP_AERA ]; then
                                          NEXT "Netcard" && continue
                                       else
                                          NMAP_AREA
                                       fi && break
                                    else
                                        NEXT "Netcard" && continue
                                    fi && break
                              done;;
                          N|n)
                              while :; do
                                    read -p "输入指定网段:" IP_AERA
                                    if [[ $IP_AERA =~ [0-9]+\.[[:digit:]]+\.[0-9]+\.[[:digit:]]+ ]];  then
                                        NMAP_AREA
                                    else
                                        NEXT && continue
                                    fi && exit
                              done;;
                            *)
                              NEXT "Option" && continue;;
                      esac && exit
                  done;;
             7)  
                  while :; do
                      read -p "输入主机文件(文件内容必须一行一个):" host_ip
                      if [ -f $host_ip -a -s $host_ip ]; then
                            nmap -sS -T4 -v -n -Pn --open -iL $host_ip
                      else
                            NEXT "file" && continue
                      fi && exit
                  done;;
             8)
                  TARGET_LOCK;
                  while true; do
                  read -p "Input script name:" script_name;
                  if { ls /usr/bin/../share/nmap/scripts|grep $script_name; } &>$NULL; then
                     nmap -n -v --script $script_name $tar_IP && break;
                  else
                     echo -e "\033[31m-\033[0m]Scipt $script_name not exist,please input again" && continue
                  fi && exit
                  done && break;;                   
             *)
                  NEXT "Option" && continue;;
           esac && break;
        done && break;
                  };;
    2)
    DPKG hydra && { 
    echo -e "\033[33m1.SSH爆破\033[0m";
    echo -e "\033[33m2.Redesktop爆破\033[0m";
    echo -e "\033[33m3.FTP爆破\033[0m";
    echo -e "\033[33m4.Telnet爆破\033[0m";
    echo -e "\033[33m5.MySql爆破\033[0m";
    echo -e "\033[33m6.smb爆破\033[0m";
    echo -e "\033[33m7.mssql爆破\033[0m";
    echo -e "\033[33m8.其他协议爆破\033[0m";
    while true;do
        read -p "Input option:"
        case ${REPLY} in
            1)
                PROTOCOL ssh;;
            2)
                PROTOCOL rdp;;
            3)
                PROTOCOL ftp;;
            4)
                PROTOCOL telnet;;   
            5)
                PROTOCOL mysql;;
            6)
                PROTOCOL smb;;
            7) 
                PROTOCOL mssql;;
            8)
                echo "Supported services:"
                for i in ${OTHER_PROTOCOL[@]};do
                   echo $i 
                done|tr '\n' ' '
                echo
                while :
                do
                   printf "\nInput service name:"
                   read service
                   if { for i in ${OTHER_PROTOCOL[@]};do echo $i;done|grep -Po "^${service}$"; } &>/dev/null; then
                      PROTOCOL $service
                   else
                      NEXT "Service" && continue
                   fi
                done;;
              *)
                NEXT "Option" && continue;;
        esac && break
    done;
                   };;
  *)
      NEXT;;
esac
done
