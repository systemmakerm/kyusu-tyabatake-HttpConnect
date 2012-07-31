require 'rho/rhocontroller'
require 'helpers/browser_helper'

class HttpConnectController < Rho::RhoController
  include BrowserHelper

  @@server_uri = "http://192.168.1.209:3000"

  #HTTP通信機能TOPページ
  def index
    render
  end

  #GETでアクセスする
  def get_access
    #GETメソッドでHTTP通信をする
    Rho::AsyncHttp.get(
      #接続先URL
      :url             =>  @@server_uri + '/asyncs.json',                  #各メソッド共通項目
      #通信のヘッダー情報
      :headers         =>  {"Cookie" => "cookieなどを送る時に使用する"},   #各メソッド共通項目
      #通信が終了したら入るコールバックを設定
      :callback        =>  (url_for(:action => :http_callback)),           #各メソッド共通項目
      #コールバックに渡すパラメータを設定
      :callback_param  =>  "test=test",                                    #各メソッド共通項目
      #認証情報を設定(ベーシック認証)
      :authentication  => {                                                #各メソッド共通項目
                            #認証のタイプを設定
                            :type       =>  :basic,
                            #認証先に渡す文字列を設定
                            :username  =>  "systemmakerm",
                            :password  =>  "systemmakerm"
                          },
      #署名の検証を行うかどうか
      :ssl_verify_peer =>  true                                            #各メソッド共通項目
    )
    render :string => "接続中....."
  end

  #POSTでアクセスする
  def post_access
    #POSTメソッドでHTTP通信をする
    Rho::AsyncHttp.post(
      :url             => @@server_uri + '/asyncs.json',
      #外部にPOSTするデータ
      :body            => "username=systemmakerm&password=systemmakerm",
      :callback        => url_for(:action => :http_callback)
      #違うメソッでのアクセスも出来る(例：PUT)
      #:http_command    => "put"
    )
    render :string => "接続中....."
  end

  #ダウンロード
  def download
    #HTTP通信でファイルをダウンロードする
    Rho::AsyncHttp.download_file(
      #ダウンロードするファイルのURL
      :url      => @@server_uri + '/robots.txt',
      #ファイルのダウンロード先
      :filename => File.join(Rho::RhoApplication::get_base_app_path(), 'test.txt'),
      :callback => url_for(:action => :http_callback)
    )
    render :string => "ダウンロード中"
  end

  #アップロード
  def upload
    #アップロードするファイルパスの作成
    file_name = File.join(Rho::RhoApplication::get_base_app_path(), 'test.png')
    #ファイルが既に存在するかどうか
    unless File.exists?(file_name)
      #ファイルの新規作成
      new_file = File.new(file_name, "w")
      #新規ファイルへの書き込み
      new_file.write("テストデータです")
      #ファイルを閉じる
      new_file.close
    end

    #HTTP通信でファイルをアップロードする
    Rho::AsyncHttp.upload_file(
      #アップロード先URL
      :url       => @@server_uri + '/asyncs.json',
      #複数のファイルを指定
      :multipart => [
        {
          #アップロードするファイルのパス
          :filename      => file_name,
          #filenameのベースディレクトリ
          :filename_base => 'file_upload',
          #アップロードするファイルのパラメータの名前
          :name          => 'image',
          #アップロードするファイルの種類
          :content_type  => "application/octet-stream"
        },
        {
          #アップロードするデータ
          :body         => "この文字列がアップロードされます",
          :name         => 'text',
          :content_type => "plain/text"
        }
      ],
      :callback => (url_for(:action => :http_callback))
    )
    render :string => "アップロード中"
  end

  #各HTTPメソッドのコールバック
  def http_callback
    #通信に成功したかどうか
    if @params['status'] == 'ok'
      msg = "通信に成功しました"
    else
      msg = "通信に失敗しました"
    end
    Alert.show_popup(
      #通信時の結果のログを出力
      :message => "#{@params}",
      :title   => msg,
      :buttons => ["了解"]
    )
    WebView.navigate(url_for(:action => :index))
  end
end
