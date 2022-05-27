using Azure;
using Azure.Data.Tables;
using Azure.Identity;
using ISignupRepositoryNamespace;
using RegisterFormModelNamespace;

namespace SignupRepositoryNamespace
{
    public class SignupRepository : ISignupRepository
    {
        public List<PersonalDetailsModel> DoesUserExists(string storageurl, string tablename, string filterColumn, string filterValue)
        {
            
            TableClient _tableClient = new TableClient(new Uri(storageurl), tablename, new DefaultAzureCredential());
            List<PersonalDetailsModel> _employee = new List<PersonalDetailsModel>();

            Pageable<TableEntity> queryResultsFilter = _tableClient.Query<TableEntity>(filter: $" {filterColumn} eq '{filterValue}' ");
            foreach(TableEntity _tableEntity in queryResultsFilter)
            {
                _employee.Add(new() {Contact=_tableEntity.GetString(filterColumn)});
            }
            
            return _employee;
        }

        public string SaveUsersIntoDatabase(TableEntity entity, string tablename, string storageurl)
        {
            TableClient _tableClient = new TableClient(new Uri(storageurl), tablename, new DefaultAzureCredential());
           _tableClient.AddEntity(entity);
           
            return "Entity Added!";
        }
    }
}