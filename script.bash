function help(){ # コマンド一覧を表示する
    cat ./script.bash | grep "^function [A-z]"
}
function create(){ # カレントディレクトリにプロジェクトを作成する
    sfdx force:project:create --manifest --projectname .
}
function setting(){ # settingファイルを独自のものに置き換える
    mkdir manifest

    # スクリプトダウンロード
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/script.bash

    # git ignore設定
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/.gitignore

    # git .gitattributes設定
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/.gitattributes

    # force ignore設定
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/.forceignore

    # prettire設定
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/.prettierignore
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/.prettierrc

    # マニフェスト設定
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/manifest/package.xml
    mv package.xml manifest/

    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/manifest/package-dev.xml
    mv package-dev.xml manifest/
    
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/manifest/package-setting.xml
    mv package-setting.xml manifest/
    
    curl -H 'Cache-Control: no-cache' -L -O https://raw.githubusercontent.com/yfujii01/salesforce-util/master/manifest/package-other.xml
    mv package-other.xml manifest/
}
function auth_prod(){ # auth login する(本番・開発用)
    sfdx force:auth:web:login -r https://login.salesforce.com --setdefaultusername
}
function auth_sand(){ # auth login する(Sandbox用)
    sfdx force:auth:web:login -r https://test.salesforce.com --setdefaultusername
}
function pull(){ # retrieve する(./manifest/package.xml使用)
    sfdx force:source:retrieve --manifest ./manifest/package.xml
}
function mdapi_pull(){ # mdapiを使用してメタデータのダウンロード～ソースへの変換を行う
    dir=./tmp_retrieve
    mkdir $dir
    sfdx force:mdapi:retrieve -s -r $dir -k ./manifest/package.xml
    unzip ./tmp_retrieve/unpackaged.zip -d $dir
    sfdx force:mdapi:convert -r $dir

    # dup削除
    # find . -name "*.dup" -delete
    # 重複データがあれば*.dupが作成されるのでリネームして上書き
    find . -name "*.dup" -print0 | while read -r -d '' file; do mv "$file" "${file%%.dup}"; done

    rm -rf $dir
}
function push(){ # deploy する(./manifest/package.xml使用)
    sfdx force:source:deploy --manifest ./manifest/package.xml
}
function mdapi_push(){ # mdapiを使用してpushする
    deploy_dir=./tmp_deploy
    sfdx force:source:convert -d $deploy_dir
    sfdx force:mdapi:deploy -d $deploy_dir -w 100
    rm -rf $deploy_dir
}
function execute(){
    sfdx force:apex:execute
}


# 引数に指定した関数を実行する
for x in "$@"
do
    set -x
    $x
    set +x
done

# 引数が指定されない場合はhelpを実行する
if [ -z "$@" ]; then
    set -x
    help
    set +x
fi
