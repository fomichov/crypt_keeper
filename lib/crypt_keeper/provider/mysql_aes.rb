require 'crypt_keeper/log_subscriber/mysql_aes'

module CryptKeeper
  module Provider
    class MysqlAes
      include CryptKeeper::Helper::SQL

      attr_accessor :key

      # Public: Initializes the encryptor
      #
      #  options - A hash, :key is required
      def initialize(options = {})
        legacy
        ActiveSupport.run_load_hooks(:crypt_keeper_mysql_aes_log, self)

        @key = options.fetch(:key) do
          raise ArgumentError, "Missing :key"
        end
      end

      # Public: Encrypts a string
      #
      # Returns an encrypted string
      def encrypt(value)
        Base64.encode64 escape_and_execute_sql(
          ["SELECT AES_ENCRYPT(?, ?)", value, key]).first
      end

      # Public: Decrypts a string
      #
      # Returns a plaintext string
      def decrypt(value)
        escape_and_execute_sql(
          ["SELECT AES_DECRYPT(?, ?)", Base64.decode64(value), key]).first
      end

      private

      def legacy
        unless ENV['CRYPT_KEEPER_IGNORE_LEGACY_DEPRECATION']
          warn "[DEPRECATION] MySqlAes Legacy is now deprecated. Please see http://git.io/nXXOlg"
        end
      end
    end
  end
end