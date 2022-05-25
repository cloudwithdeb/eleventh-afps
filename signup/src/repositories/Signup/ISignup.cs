using Azure.Data.Tables;
using RegisterFormModelNamespace;

namespace ISignupRepositoryNamespace
{
    public interface ISignupRepository
    {
        public List<PersonalDetailsModel> DoesUserExists(string contact, string email, string storageurl, string tablename, string filterColumn, string filterValue);
        public string SaveUsersIntoDatabase(TableEntity entity, string tablename, string storageurl);
    }
}