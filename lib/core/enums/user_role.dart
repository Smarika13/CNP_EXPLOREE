enum UserRole{
    user,
    admin,

    String get value{
        switch(this) {
            case UserRole.user:
                return 'user';
            case UserRole.admin:
                return 'admin';
        }
    }

    static UserRole fromString(String role){
        switch(role.toLowerCase()):{
            case: 'admin':
                return UserRole.admin;
            case: 'user':
                return UserRole.user;
        }
    }
}