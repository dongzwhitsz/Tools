#!/bin/bash
# 作者：董志伟
# 2021/8/27 从第一个脚本开始牛逼起来。
set -x

setup_base_environ() {
	ping -c 1 114.114.114.114 > /dev/null 2>&1	
	if [ $? != 0 ]; then		
        echo "network error"		
        exit 1;	
	fi
	
	echo "setup base environ"
  mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
  wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
  yum clean all
  yum -y update
  yum makecache
  # build essentials
  yum -y groupinstall "Development Tools" "Development Libraries"
  yum install -y net-tools
  yum install -y kernel-devel

  echo "installing Java"
  yum install -y java-1.8.0-openjdk-devel.x86_64
  cat << EOF >> /etc/profile
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.171-8.b10.el6_9.x86_64
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin
EOF
  source /etc/profile
  java -version > /dev/null
  if [ $? != 0 ]; then
      echo "java installed failed"
      exit;
  fi
  echo "installing Python"
  yum -y install python3
  yum –y install python3-pip

  mkdir ~/.pip
  cat << EOF > ~/.pip/pip.conf
[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host = pypi.tuna.tsinghua.edu.cn
EOF
    echo "setup_base_environ ok"
}

setup_tmux_vim() {
	# tmux & vim 
  echo "setup tmux & vim"
  yum install -y libevent-devel ncurses-devel
  TMUX_URL=https://github.com/tmux/tmux/releases/download/3.2/tmux-3.2.tar.gz
  TARGZ_NAME=`echo $TMUX_URL | awk -F/ '{print $NF}'` # 获取awk的最后一个元素
  wget $TMUX_URL -O /opt/$TARGZ_NAME
  TMUX_NAME=`echo $TMUX_NAME | awk -F '.tar.gz' '{print $1}'`
  tar /opt/$TMUX_NAME -xvf -C /opt/
  cd /opt/TMUX_NAME
  ./configure
  make && sudo make install
  yum install -y vim
  wget https://raw.githubusercontent.com/dongzwhitsz/Tools/main/.vimrc -O /home/dongzw/.vimrc
  echo "setup_tmux_vim ok"
}

setup_mysql() {
	echo "setup mysql"
	items=`rpm -qa |grep -i mysql`
	# 如果系统中已经装过了mysql
	if [ ${items[@]} != 0 ]; then
        echo "uninstalling old mysql"
        for i in $items; do 
          yum -y remove $i
        done
        rm -rf /etc/my.cnf
        rm -rf /var/log/mysqld.log
	fi
    wget http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
    rpm -ivh mysql-community-release-el7-5.noarch.rpm
    rm -rf mysql-community-release-el7-5.noarch.rpm
    yum -y update
    yum -y install mysql-server
    chown -R mysql:mysql /var/lib/mysql
    systemctl start mysqld
    mysqladmin -u root -pdongzhiwei 
    mysql -u root -pdongzhiwei -e "grant all privileges on *.* to 'root'@'%' identified by 'dongzhiwei' with grant option;flush privileges;"
    firewall-cmd --permanent --add-service=mysql  #永久开放mysql
    # firewall-cmd --zone=public --add-port=3306/tcp --permanent  #在public中永久开放3306端口
    firewall-cmd reload
    echo "setup_mysql ok"
}

setup_redis() {
	# redis配置参考link：https://www.cnblogs.com/stulzq/p/9288401.html
	REDIS_URL=http://download.redis.io/releases/redis-6.0.9.tar.gz
	TARGZ_NAME=`echo $REDIS_URL | awk -F/ '{print $NF}'`
	REDIS_NAME=`echo $TARGZ_NAME | awk -F '.tar.gz' '{print $1}'`
    wget $REDIS_URL -O /opt/$TARGZ_NAME
    tar /opt/$TARGZ_NAME -xvf -C /opt/
    make & make install PRIFIX=/opt/redis
    mkdir /opt/redis/etc
    cp /opt/$REDIS_NAME/redis.cnf /opt/redis/etc/
    # sed daemon no ==> yes
    sed -i "s/daemon no/daemon yes/g" /opt/redis/etc/redis.cnf
    firewall-cmd --permanent --add-service=redis  #永久开放redis
    firewall-cmd reload
    echo "setup_redis ok"
}

setup_zookeeper() {
	ZOOKEEPER_URL=https://dlcdn.apache.org/zookeeper/zookeeper-3.7.0/apache-zookeeper-3.7.0-bin.tar.gz
	TARGZ_NAME=`echo $ZOOKEEPER_URL | awk -F/ '{print $NF}'`
	ZOOKEEPRE_NAME=`echo $TARGZ_NAME | awk -F '-bin.tar.gz' '{print $1}'`
	wget $ZOOKEEPER_URL -O /opt/$TARGZ_NAME
	tar /opt/$TARGZ_NAME -xvf -C /opt/
	mkdir /opt/$ZOOKEEPRE_NAME/data
	mkdir /opt/$ZOOKEEPRE_NAME/logs
	cat << EOF > conf/zoo.cfg
tickTime = 2000
dataDir = /opt/zookeeper-3.7.0/data
dataLogDir = /opt/zookeeper-3.7.0/logs
clientPort = 2181
initLimit = 5
syncLimit = 2
EOF
    firewall-cmd --permanent --add-service=zookeeper
    firewall-cmd reload
    echo "setup_zookeeper ok"
}

setup_nacos() {
	NACOS_URL=https://github.com/alibaba/nacos/releases/download/2.0.3/nacos-server-2.0.3.tar.gz 
	curl $NACOS_URL -O /opt/nacos-server-2.0.3.tar.gz
  tar -xvf /opt/nacos-server-2.0.3.tar.gz  -C /opt/
	cd /opt/nacos-server-2.0.3
	echo "setup_nacos ok"
}
#
#setup_kafka() {
#}
#
#setup_es() {
#}
#
#my_server_start() {
#}
#
#my_server_stop() {
#}
#
#my_server_status() {
#}


servers=(mysql redis)

# setup_base_environ
# setup_tmux_vim
# setup_mysql
# setup_redis
case $1 in
	base)
		setup_base_environ;;
	input)
		setup_tmux_vim;;
	mysql)
		setup_mysql;;
	redis)
		setup_redis;;
  ?)
    echo "Unknown parameter"
    exit 1;;
esac
