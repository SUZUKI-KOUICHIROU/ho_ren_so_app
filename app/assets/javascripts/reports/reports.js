/*global $*/

$(document).on('turbolinks:load', function(){
  // 報告投稿ページ(プロジェクトのセレクトボックスの選択肢に応じて報告フォームを変化させる処理)
  $(function($) {
    $('.box-project-report').on('change', '.reprt-project-select-box', function(){
      console.log( "チェンジイベントを感知しました(￣^￣)ゞ" )

      // data属性のuser_idを取得
      var user_id = $(this).data('userId');
      console.log( "user_idだよ(*ﾟ▽ﾟ)ﾉ", user_id )

      // select_boxの値を取得
      var project_id = $(this).val();
      console.log( "project_idだよ(*ﾟ▽ﾟ)ﾉ", project_id )

      $.ajax({
        url: '/report_forms/report_form_switching',
        data: { user_id: user_id,
                project_id: project_id,
        },
      })
    });
  });
});
