#!/usr/bin/env ruby
# iKnow API �𗘗p���邽�߂̃v���L�V
# �N���X�T�C�g�Ƀ��N�G�X�g���o�����߂ɗ��p
# method: post, get, delete
# query: query string
# data: 

require 'cgi'
require 'open-uri'


class WebServiceProxy
end

class IknowApiProxy < WebServiceProxy
	@@uri = URI.parse('http://api.iknow.co.jp/')
	def initialize(api_key)
		@api_key = api_key
	end
end

