using System.ComponentModel.DataAnnotations;

namespace RegisterFormModelNamespace
{
       
    public class SymptionInfoModel
    {
        public bool? AttendBefore {get; set;}
        public bool? OfficialDelegate {get; set;}
        public string? EventType {get; set;}
        public bool? CanShareRoom {get; set;}
        public int? TShirtSize {get; set;}
        public string? PaymentPackage {get; set;}
    }

    public class EmergencyContactModel
    {
        public string? Fullname {get; set;}
        public string? Contact {get; set;}
        public string? WhatsappPhone {get; set;}
        public string? Email {get; set;}
    }

    public class PersonalDetailsModel
    {
        
        [Required(ErrorMessage = "Fullname is required. Thank you!")]
        public string? Fullname {get; set;}

        public string? Email {get; set;}

        [Required(ErrorMessage = "Contact is required. Thank you!")] 
        public string? Contact {get; set;}

        [Required(ErrorMessage = "Gender is required. Thank you!")] 
        public string? Gender {get; set;}

        [Required(ErrorMessage = "Date Of Birth is required. Thank you!")] 
        public string? DOB {get; set;}

        public string? WhatsappPhone {get; set;}

        [Required(ErrorMessage = "Nationality is required. Thank you!")] 
        public string? Nationality {get; set;}
        
        public string? Association {get; set;}

        [Required(ErrorMessage = "Year of Study is required. Thank you!")] 
        public string? YearOfStudy {get; set;}

        [Required(ErrorMessage = "Passport Number is required. Thank you!")] 
        public string? PassportNumber {get; set;}

        [Required(ErrorMessage = "Passport expire date is required. Thank you!")] 
        public string? PassportExpireDate {get; set;}

        [Required(ErrorMessage = "Medical Condition is required. Thank you!")] 
        public string? MedicalCondition {get; set;}

        public string? FoodOrBaveragealergy {get; set;}
        public string? FileUrl {get; set;}
        public string? PictureUrl {get; set;}
        internal string? SymptionInfoRowKey {get; set;}
        internal string? EmergencyRowKey {get; set;}
    }
 
    public class RegistrationFormModel
    {
        public PersonalDetailsModel? PersonalDetails {get; set;}
        public SymptionInfoModel? Symption {get; set;}
        public EmergencyContactModel? Emergency {get; set;}
    }
}