# frozen_string_literal: true

class User < ApplicationRecord
  rolify

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  has_one :wallet, dependent: :destroy

  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :fund_transactions, dependent: :destroy

  enum :gender, { male: 0, female: 1, cant_specify: 2 }

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true, allow_blank: false,
                   format: { with: /\A[^0-9`!@#$%\^&*+_=]+\z/ }
  validates :gender, inclusion: { in: User.genders.keys }
  validates :password, length: { maximum: 8 }
  validates :cnic, presence: true, length: { maximum: 13 }, uniqueness: true
  validates :address, presence: true
  validates :contact_no, presence: true

  after_create :assign_user_role, :create_user_wallet

  def assign_user_role
    add_role(:user)
  end

  def create_user_wallet
    create_wallet(amount: 0)
  end

  def self.find_payee(info)
    where(email: info).or(where(contact_no: info))
  end

  def self.user_wallet(id)
    find(id).wallet
  end
end
