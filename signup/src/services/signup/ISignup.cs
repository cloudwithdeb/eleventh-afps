using RegisterFormModelNamespace;

namespace ISignupServiceNamespace
{
    public interface ISignupService
    {
        public string signupServiceSignUp(RegistrationFormModel user);
    }
}