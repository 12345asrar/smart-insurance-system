class InsuranceRepository {
  static final InsuranceRepository _instance = InsuranceRepository._internal();
  factory InsuranceRepository() => _instance;
  InsuranceRepository._internal();

  // كلمات المرور الافتراضية
  String adminPassword = 'admin';
  String clientPassword = '123';

  bool verifyAdminPassword(String password) => adminPassword == password;
  bool verifyClientPassword(String password) => clientPassword == password;

  bool changeAdminPassword(String oldPass, String newPass) {
    if (adminPassword == oldPass) {
      adminPassword = newPass;
      return true;
    }
    return false;
  }

  bool changeClientPassword(String oldPass, String newPass) {
    if (clientPassword == oldPass) {
      clientPassword = newPass;
      return true;
    }
    return false;
  }

  final List<Map<String, dynamic>> benefitRequests = [];
  final List<Map<String, dynamic>> insuredMembers = [];
  final List<Map<String, dynamic>> journalEntries = [];
  final List<Map<String, dynamic>> inspectionVisits = [];
  final List<Map<String, dynamic>> freelancers = [];

  void addBenefitRequest(Map<String, dynamic> request) {
    benefitRequests.insert(0, request);
  }

  void addInsuredMember(Map<String, dynamic> member) {
    insuredMembers.insert(0, member);
  }

  void addJournalEntry(Map<String, dynamic> entry) {
    journalEntries.insert(0, entry);
  }

  void addInspectionVisit(Map<String, dynamic> visit) {
    inspectionVisits.insert(0, visit);
  }

  void addFreelancer(Map<String, dynamic> freelancer) {
    freelancers.insert(0, freelancer);
  }
}
