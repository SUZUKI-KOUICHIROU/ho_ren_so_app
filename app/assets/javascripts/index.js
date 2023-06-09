$(document).on('turbolinks:load', function(){
  // 報告、連絡、相談、一覧ページ((プロジェクトのセレクトボックスの選択肢に応じて一覧を変化させる処理)
  $(function($) {
    $('.box-project-select').on('change', '.index-project-select-box', function(){

      // data属性のuser_idを取得
      var user_id = $(this).data('userId');

      // data属性のuser_idを取得
      var list_type = $(this).data('listType');

      // select_boxの値を取得
      var project_id = $(this).val();

      $.ajax({
        url: '/index/index_switching',
        data: { user_id: user_id,
                project_id: project_id,
                list_type: list_type
        },
      })
    });
  });
});
