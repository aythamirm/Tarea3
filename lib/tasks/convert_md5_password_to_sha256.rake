namespace :manager_password do

  desc "Update organization's students read books averages"
  task :convert_md5_password_to_sha256 => :environment do
    
    printf "******START THE SCRIPT*******\n"

    array_password_md5 = ManagerPassword.read_file_by_line_and_convert_to_array_of_hashes "passwords_md5.txt"

    
    hash_with_clear_text = ManagerPassword.get_password_hashmd5_online array_password_md5

    ManagerPassword.write_file_by_line "plain.txt", hash_with_clear_text

    hash_with_password_sha256 = ManagerPassword.create_new_password_sha256 hash_with_clear_text

    ManagerPassword.write_file_by_line "new_passwords.txt", hash_with_password_sha256

    printf "******END THE SCRIPT*************\n"

  end

end 