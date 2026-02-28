import 'package:get/get.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/loan_payment_model.dart';
import '../../data/repositories/loan_repository.dart';

class LoanController extends GetxController {
  final LoanRepository _repository = LoanRepository();
  
  final RxList<LoanModel> lentLoans = <LoanModel>[].obs;
  final RxList<LoanModel> owedLoans = <LoanModel>[].obs;
  final RxDouble totalLent = 0.0.obs;
  final RxDouble totalOwed = 0.0.obs;
  final RxDouble netPosition = 0.0.obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadLoans();
  }

  void loadLoans() {
    isLoading.value = true;
    lentLoans.value = _repository.getByType(LoanType.lent);
    owedLoans.value = _repository.getByType(LoanType.owed);
    totalLent.value = _repository.getTotalLent();
    totalOwed.value = _repository.getTotalOwed();
    netPosition.value = _repository.getNetPosition();
    isLoading.value = false;
  }

  Future<void> addLoan({
    required LoanType type,
    required String personName,
    required double amount,
    required DateTime date,
    String? note,
  }) async {
    await _repository.create(
      type: type,
      personName: personName,
      amount: amount,
      date: date,
      note: note,
    );
    loadLoans();
  }

  Future<void> updateLoan(LoanModel loan) async {
    await _repository.update(loan);
    loadLoans();
  }

  Future<void> deleteLoan(String id) async {
    await _repository.delete(id);
    loadLoans();
  }

  Future<void> addPayment(String loanId, double amount, {String? note}) async {
    await _repository.addPayment(loanId, amount, note: note);
    loadLoans();
  }

  Future<void> markAsCompleted(String id) async {
    await _repository.markAsCompleted(id);
    loadLoans();
  }

  LoanModel? getLoanById(String id) {
    return _repository.getById(id);
  }

  List<LoanPaymentModel> getPayments(String loanId) {
    return _repository.getPayments(loanId);
  }
}
