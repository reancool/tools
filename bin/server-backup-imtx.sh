#!/bin/sh
# Django project backup script
# Author: TualatriX

set -e
set -x

SOURCE_PATH="$HOME/public_html/imtx.me"
PROJECT_NAME="imtx"
DEST_PATH="$HOME/Backup/$PROJECT_NAME-backup"
PRE=$PROJECT_NAME-`date +%F`
KERNEL=`uname -s`

if [ ! -e $DEST_PATH/$PROJECT_NAME ]
then
    mkdir -p $DEST_PATH/$PROJECT_NAME
fi


cd $SOURCE_PATH; tar cf - --exclude '.git' $PROJECT_NAME | gzip > $DEST_PATH/$PRE.tar.gz

cd $DEST_PATH

tar zxvf $PRE.tar.gz $PROJECT_NAME/$PROJECT_NAME/local_settings.py
touch $PROJECT_NAME/$PROJECT_NAME/__init__.py

cd $DEST_PATH/$PROJECT_NAME

if [ -f $PROJECT_NAME/local_settings.py ];then
    if [ $KERNEL = "Darwin" ]; then
        gsed -i '/global_setting/d' $PROJECT_NAME/local_settings.py
    elif [ $KERNEL = "Linux" ]; then
        sed -i '/global_setting/d' $PROJECT_NAME/local_settings.py
    fi

    DB_NAME=`python -c "import $PROJECT_NAME.local_settings;print $PROJECT_NAME.local_settings.DATABASES['default']['NAME']"`
    DB_USER=`python -c "import $PROJECT_NAME.local_settings;print $PROJECT_NAME.local_settings.DATABASES['default']['USER']"`
    DB_PASSWORD=`python -c "import $PROJECT_NAME.local_settings;print $PROJECT_NAME.local_settings.DATABASES['default']['PASSWORD']"`
    rm -r $PROJECT_NAME
else
    echo "Something wrong ..."
    exit 1
fi

cd $DEST_PATH

mysqldump -u${DB_USER} -p${DB_PASSWORD} $DB_NAME | gzip > $PRE.sql.gz

web-backup.rb $DEST_PATH/$PRE.sql.gz
web-backup.rb $DEST_PATH/$PRE.tar.gz
