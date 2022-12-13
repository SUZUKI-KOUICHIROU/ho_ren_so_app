require 'rails_helper'

RSpec.describe Project, type: :model do
  subject(:project) { FactoryBot.build(:project) }

  describe 'プロジェクト新規登録' do
    it '全てのカラムに値があれば登録出来る' do
      expect(project).to be_valid
    end

    context 'nameカラム' do
      it 'nameがなければ登録できない' do
        expect(build(:project, name: '')).not_to be_valid
      end

      it '20文字以下であること' do
        expect(build(:project, name: 'a' * 21)).not_to be_valid
      end
    end

    it 'leader_idがなければ登録できない' do
      expect(build(:project, leader_id: '')).not_to be_valid
    end

    it 'report_frequencyがなければ登録できない' do
      expect(build(:project, report_frequency: '')).not_to be_valid
    end

    it 'next_report_dateがなければ登録できない' do
      expect(build(:project, next_report_date: '')).not_to be_valid
    end

    context 'reported_flagカラム' do
      it 'trueとfalseは登録出来る' do
        expect(project).to allow_value(true).for(:reported_flag)
        expect(project).to allow_value(false).for(:reported_flag)
      end

      it 'nilは登録出来ない' do
        expect(project).not_to allow_value(nil).for(:reported_flag)
      end
    end
  end
end
