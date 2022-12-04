
/*global $*/

$(document).on('turbolinks:load', function(){

  //プロジェクト名の入力値を取得する処理
  $(function($) {
    $('#project-new-edit').on('input', '.project-name-text-box', function(){
      nameText = $(this).val();
    });
  });

    //プロジェクト概要の入力値を取得する処理
    $(function($) {
      $('#project-new-edit').on('input', '.project-description-textarea-box', function(){
        descriptionText = $(this).val();
      });
    });

  // プロジェクト登録、編集モーダルウインドウ((ラジオボタンの選択肢に応じてコンテンツを変化させる処理)
  $(function($) {
    $('#project-new-edit').on('change', '.project-radio', function(){

      // nameTextが定義されていない場合、nameTextを定義
      if (typeof nameText == 'undefined') {
        nameText = $('input:text[name="project[project_name]"]').val();
      }

      // descriptionTextが定義されていない場合、descriptionTextを定義
      if (typeof descriptionText == 'undefined') {
        descriptionText = $('textarea[name="project[description]"]').val();
      }

      // radiobuttonのvalue値を取得しform_typeに代入
      var form_type = $('input:radio[name="project[report_frequency_selection]"]:checked').val();

      // radiobutton要素のdata属性(user_id)値を取得しuser_idに代入
      var user_id = $('input:radio[name="project[report_frequency_selection]"]:checked').data('userId');

      // radiobutton要素のdata属性(project_id)値を取得しproject_idに代入
      // radiobutton要素のdata属性(project_id))が存在している場合とそうでない場合でproject_idに代入する値を変更
      if( typeof $('input:radio[name="project[report_frequency_selection]"]:checked').data('projectId') !== 'undefined' ) {
        var project_id = $('input:radio[name="project[report_frequency_selection]"]:checked').data('projectId');
      } else {
        var project_id = 'nill'
      }

      $.ajax({
        url: '/input_forms/frequency_input_form_switching',
        data: { project_name: nameText,
                project_description: descriptionText,
                form_type: form_type,
                user_id: user_id,
                project_id: project_id,
        },
      })
    });
  });

  // プロジェクト登録、編集モーダルウインドウ(報告頻度のnumberfieldが変化したら、次回報告日を動的に算出する処理)
  $(function($) {
    $('#project-new-edit').on('change', '#report_frequency', function(){
      console.log( "チェンジイベントを感知しました(￣^￣)ゞ" )

      // numberfieldの値を取得しfrequencyに代入
      var frequency = $(this).val();
      console.log( "numberfieldの値だよ(*ﾟ▽ﾟ)ﾉ", frequency );

      // 本日の日付を取得しnext_report_date変数に代入
      var next_report_date = new Date();
      console.log( "当日の日付だよ(*ﾟ▽ﾟ)ﾉ", next_report_date );

      // 取得した本日の日付をfrequencyの値分の加算した日付を取得
      next_report_date.setDate( next_report_date.getDate() + Number( frequency ) - 1);
      console.log( "当日の日付をnumberfieldの値分進めた日付だよ(*ﾟ▽ﾟ)ﾉ", next_report_date );

      var yearNum = next_report_date.getFullYear();
      var monthNum = next_report_date.getMonth() + 1;
      var dayNum = next_report_date.getDate();
      var weekNum = next_report_date.getDay();
      var week = [ "日", "月", "火", "水", "木", "金", "土" ][weekNum];
      var aDateStr = String( yearNum ) + "年" + String( monthNum ) + "月" + String( dayNum ) + "日" + "(" + String( week ) + ")";
      var inputvalDate = String( yearNum ) + "-" + String( monthNum ) + "-" + String( dayNum );
      console.log( "a要素にセットする日付だよ(*ﾟ▽ﾟ)ﾉ", aDateStr );
      document.getElementById("project-next-report-date").innerHTML = `<label for="report_frequency">次回報告日</label><br>${aDateStr}`;
      console.log( "input要素にセットする日付だよ(*ﾟ▽ﾟ)ﾉ", aDateStr );
      document.getElementById("next_report_date").value = inputvalDate;
    });
  });

  // プロジェクト登録、編集モーダルウインドウ(曜日のselectfieldが変化したら、次回報告日を動的に算出する処理)
  $(function($) {
    // モーダルウインドウは追加される元のhtmlのに追加される処理なので、親となる要素にonメソッド繋げる形で記述
    $('#project-new-edit').on('change', '#project_week_select', function(){
      console.log( "チェンジイベントを感知しました(￣^￣)ゞ" )
      // セレクトフィールドの値を取得
      var weekday = $(this).val();
      console.log( "セレクトフィールドの値だよ(*ﾟ▽ﾟ)ﾉ", weekday );
      // 取得した本日の日付を1日ずつ進めて、weekdayの値と比較し次回報告日を取得
      // for文で初期値と繰り返しの条件式を指定 for (var 初期値; 繰り返し条件; 繰り返し処理)
      for (var i=0; i<7; i++) {
        // 本日の日付を取得しnext_report_date変数に代入
        var next_report_date = new Date();
        console.log( "当日の日付だよ(*ﾟ▽ﾟ)ﾉ", next_report_date );
        console.log( "iの値だよ(*ﾟ▽ﾟ)ﾉ", i );
        next_report_date.setDate( next_report_date.getDate() + i);
        console.log( "当日の日付をiの値分進めるよ(*ﾟ▽ﾟ)ﾉ", next_report_date );
        var weekNum = next_report_date.getDay();
        console.log( "weekNumの値だよ(*ﾟ▽ﾟ)ﾉ", weekNum );
        var week = [ "日", "月", "火", "水", "木", "金", "土" ][weekNum];
        console.log( "weekの値だよ(*ﾟ▽ﾟ)ﾉ", week );
        //if文でweekdayとweekが同じ値時の条件分岐を指定
        if (weekday == week) {
          //weekdayとweekの値が同じならbreakで繰り返し処理を中止
          break;
        }
      }

      console.log( "算出した次回報告日の日付だよ(*ﾟ▽ﾟ)ﾉ", next_report_date );

      var yearNum = next_report_date.getFullYear();
      var monthNum = next_report_date.getMonth() + 1;
      var dayNum = next_report_date.getDate();
      var weekNum = next_report_date.getDay();
      var week = [ "日", "月", "火", "水", "木", "金", "土" ][weekNum];
      var aDateStr = String( yearNum ) + "年" + String( monthNum ) + "月" + String( dayNum ) + "日" + "(" + String( week ) + ")";
      var inputvalDate = String( yearNum ) + "-" + String( monthNum ) + "-" + String( dayNum );
      console.log( "a要素にセットする日付だよ(*ﾟ▽ﾟ)ﾉ", aDateStr );
      document.getElementById("project-next-report-date").innerHTML = `<label for="report_frequency">次回報告日</label><br>${aDateStr}`;
      console.log( "input要素にセットする日付だよ(*ﾟ▽ﾟ)ﾉ", aDateStr );
      document.getElementById("next_report_date").value = inputvalDate;
    });
  });
});
