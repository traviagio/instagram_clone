class Post < ActiveRecord::Base
  after_create :send_new_post_email
  has_many :comments, dependent: :destroy
  has_many :votes
  belongs_to :user
  has_attached_file :image,
  								styles: { thumb: "250x250>" },
  								storage: :s3,
  								s3_credentials: {
  									access_key_id: 'AKIAISJ3BURO2DLFVRKQ',
  									secret_access_key: Rails.application.secrets.secret_access_key
  								},
  								bucket: 'swagstagram'

  has_and_belongs_to_many :tags                

	def tag_names
	     tags.map{|tag| tag.name}.join(', ')
	end

	  def tag_names=(tag_names)
	  	self.tags = Tag.find_or_create_from_tag_names(tag_names)
	  end

	  def self.for_tag_or_all(tag_name)
	  	tag_name ? Tag.find_by(text: tag_name).posts : all
	  end

    def points
      votes.where(up: true).count - votes.where(up: false).count
    end

    def send_new_post_email
      PostMailer.new_post(self, user).deliver!
    end

end