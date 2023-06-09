class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :remanded, defalut: false #差し戻し食らったかを管理
      t.string :remanded_reason, defalut: "" #要再提出の理由
      t.integer :sender_id # 報告者ID
      t.string :sender_name # 報告者名
      t.string :title # 報告タイトル
      t.date :report_day # 報告日
      t.boolean :resubmitted, defalut: false # 手直し完了

      t.timestamps
    end
  end
end