class Stat < ActiveRecord::Base
	belongs_to :statable, :polymorphic => true
	attr_accessible :mean, :sd, :presence, :statable_type, :statable_id
end
