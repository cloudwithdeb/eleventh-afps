using Azure.Data.Tables;
using ISignupRepositoryNamespace;
using ISignupServiceNamespace;
using RegisterFormModelNamespace;
using SignupRepositoryNamespace;

namespace signupServiceNamespace
{
    public class SignupService : ISignupService
    {
        private readonly ISignupRepository _signuprepositry;
        private readonly string? _emergency_tablename;
        private readonly string? _symposium_tablename;
        private readonly string? _storage_account_name;
        private readonly string? _users_tablename;
        private readonly string? _container_name;
        private string? _storageurl;
        
        public SignupService(ISignupRepository signuprepositry)
        {
            _signuprepositry=signuprepositry;
            _users_tablename=Environment.GetEnvironmentVariable("USERS_TABLE_NAME");
            _storageurl=Environment.GetEnvironmentVariable("TABLE_STORAGE_ACCOUNT_URL");
            _emergency_tablename=Environment.GetEnvironmentVariable("EMERGENCY_TABLE_NAME");
            _symposium_tablename=Environment.GetEnvironmentVariable("SYMPOSIUM_TABLE_NAME");
            _storage_account_name=Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_NAME");
            _container_name = Environment.GetEnvironmentVariable("STORAGE_ACCOUNT_CONTAINER");
        }

        public string signupServiceSignUp(RegistrationFormModel user)
        {

            List<PersonalDetailsModel> does_contact_exists = _signuprepositry.DoesUserExists(_storageurl, _users_tablename, "contact", user.PersonalDetails.Contact);
            if(does_contact_exists.Count > 0)
            {
                return "Contact exists";
            }
            else
            {
                List<PersonalDetailsModel> does_email_exists = _signuprepositry.DoesUserExists(_storageurl, _users_tablename, "email", user.PersonalDetails.Email);
                if(does_email_exists.Count > 0)
                {
                    return "Email exists";
                }
                else
                {
                    var usersPK = Guid.NewGuid().ToString();
                    var usersRK = Guid.NewGuid().ToString();         

                    var emergencyPK = Guid.NewGuid().ToString();
                    var emergencyRK = Guid.NewGuid().ToString();
        
                    var symptionInfoPk = Guid.NewGuid().ToString();
                    var symptionInfoRk = Guid.NewGuid().ToString();

                    TableEntity symptionInfoModel = new TableEntity(symptionInfoPk, symptionInfoRk)
                    {
                       {"officialdelegate", user.Symption.OfficialDelegate},
                       {"paymentpackage", user.Symption.PaymentPackage},
                       {"canshareroom", user.Symption.CanShareRoom},
                       {"attendbefore", user.Symption.AttendBefore},
                       {"tshirtsize", user.Symption.TShirtSize},
                       {"date", DateTime.UtcNow.ToString("D")},
                       {"time", DateTime.UtcNow.ToString("T")},
                       {"eventtype", user.Symption.EventType}
                    };

                    TableEntity emergencyContactModel = new TableEntity(emergencyPK, emergencyRK)
                    {
                      {"whatsappphone", user.Emergency.WhatsappPhone},
                      {"date", DateTime.UtcNow.ToString("D")},
                      {"time", DateTime.UtcNow.ToString("T")},
                      {"fullname", user.Emergency.Fullname},
                      {"contact", user.Emergency.Contact},
                      {"email", user.Emergency.Email}
                    };

                    TableEntity personalDetailsModel = new TableEntity(usersPK, usersRK)
                    {
                      {"foodorbaveragealergy", user.PersonalDetails.FoodOrBaveragealergy},
                      {"passportexpiredate", user.PersonalDetails.PassportExpireDate},
                      {"symptioninforowkey", user.PersonalDetails.SymptionInfoRowKey},
                      {"medicalcondition", user.PersonalDetails.MedicalCondition},
                      {"emergencyrowkey", user.PersonalDetails.EmergencyRowKey},
                      {"passportnumber", user.PersonalDetails.PassportNumber},
                      {"whatsappPhone", user.PersonalDetails.WhatsappPhone},
                      {"nationality", user.PersonalDetails.Nationality},
                      {"association", user.PersonalDetails.Association},
                      {"yearofstudy", user.PersonalDetails.YearOfStudy},
                      {"pictureurl", user.PersonalDetails.PictureUrl},
                      {"fullname", user.PersonalDetails.Fullname},
                      {"fileurl", user.PersonalDetails.FileUrl},
                      {"contact", user.PersonalDetails.Contact},
                      {"date", DateTime.UtcNow.ToString("D")},
                      {"time", DateTime.UtcNow.ToString("T")},
                      {"gender", user.PersonalDetails.Gender},
                      {"email", user.PersonalDetails.Email},
                      {"dob", user.PersonalDetails.DOB}
                    };

                    _signuprepositry.SaveUsersIntoDatabase(personalDetailsModel, _users_tablename, _storageurl);
                    _signuprepositry.SaveUsersIntoDatabase(emergencyContactModel, _emergency_tablename, _storageurl);
                    _signuprepositry.SaveUsersIntoDatabase(symptionInfoModel, _symposium_tablename, _storageurl);
                    
                    return "Signup successfully";

                }
            }
        }

    }
}