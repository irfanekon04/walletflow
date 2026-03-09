import 'package:get/get.dart';
import '../../data/models/loan_model.dart';
import '../../data/models/loan_payment_model.dart';
import '../../data/repositories/loan_repository.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../accounts/presentation/controllers/account_controller.dart';
import '../../../transactions/data/models/transaction_model.dart';
import '../../../transactions/data/models/category_model.dart';
import '../../../transactions/data/repositories/category_repository.dart';
import '../../../transactions/presentation/controllers/transaction_controller.dart';

class LoanController extends GetxController {
  final LoanRepository _repository = LoanRepository();
  final CategoryRepository _categoryRepo = CategoryRepository();

  String? _lendCategoryId;
  String? _borrowCategoryId;
  
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
    _initLoanCategories();
    loadLoans();
  }

  Future<void> _initLoanCategories() async {
    final expenseCategories = _categoryRepo.getByType(CategoryType.expense);
    final incomeCategories = _categoryRepo.getByType(CategoryType.income);

    final lendCat = expenseCategories.where((c) => c.name.toLowerCase() == 'lend').firstOrNull;
    if (lendCat != null) {
      _lendCategoryId = lendCat.id;
    } else {
      final created = await _categoryRepo.create(
        name: 'Lend',
        type: CategoryType.expense,
        icon: 'arrow_upward',
        color: '#2196F3',
      );
      _lendCategoryId = created.id;
    }

    final borrowCat = incomeCategories.where((c) => c.name.toLowerCase() == 'borrow').firstOrNull;
    if (borrowCat != null) {
      _borrowCategoryId = borrowCat.id;
    } else {
      final created = await _categoryRepo.create(
        name: 'Borrow',
        type: CategoryType.income,
        icon: 'arrow_downward',
        color: '#FF9800',
      );
      _borrowCategoryId = created.id;
    }
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
    required String accountId,
    String? note,
  }) async {
    await _repository.create(
      type: type,
      personName: personName,
      amount: amount,
      date: date,
      accountId: accountId,
      note: note,
    );

    if (Get.isRegistered<TransactionController>()) {
      final transactionController = Get.find<TransactionController>();
      final isLent = type == LoanType.lent;
      
      final transactionNote = isLent
          ? 'Lent to $personName${note != null ? ' - $note' : ''}'
          : 'Borrowed from $personName${note != null ? ' - $note' : ''}';
      
      await transactionController.addTransaction(
        accountId: accountId,
        type: isLent ? TransactionType.expense : TransactionType.income,
        amount: amount,
        categoryId: isLent ? _lendCategoryId : _borrowCategoryId,
        note: transactionNote,
        date: date,
      );
    }

    loadLoans();
    _refreshAccountBalance(accountId);
  }

  Future<void> updateLoan(LoanModel loan) async {
    await _repository.update(loan);
    loadLoans();
  }

  Future<void> deleteLoan(String id) async {
    await _repository.delete(id);
    loadLoans();
  }

  Future<void> addPayment({
    required String loanId,
    required double amount,
    required String accountId,
    String? note,
  }) async {
    final loan = _repository.getById(loanId);
    if (loan == null) return;

    await _repository.addPayment(
      loanId: loanId,
      amount: amount,
      accountId: accountId,
      note: note,
    );

    if (Get.isRegistered<TransactionController>()) {
      final transactionController = Get.find<TransactionController>();
      final isLent = loan.type == LoanType.lent;
      
      final transactionNote = isLent
          ? 'Payment received from ${loan.personName}${note != null ? ' - $note' : ''}'
          : 'Payment made to ${loan.personName}${note != null ? ' - $note' : ''}';
      
      await transactionController.addTransaction(
        accountId: accountId,
        type: isLent ? TransactionType.income : TransactionType.expense,
        amount: amount,
        categoryId: isLent ? _borrowCategoryId : _lendCategoryId,
        note: transactionNote,
        date: DateTime.now(),
      );
    }

    loadLoans();
    _refreshAccountBalance(accountId);
  }

  void _refreshAccountBalance(String accountId) {
    if (Get.isRegistered<AccountController>()) {
      Get.find<AccountController>().loadAccounts();
    }
  }

  Future<void> markAsCompleted(String id) async {
    await _repository.markAsCompleted(id);
    loadLoans();
  }

  LoanModel? getLoanById(String id) {
    return _repository.getById(id);
  }

  AccountModel? getAccountById(String id) {
    return _repository.getAccountById(id);
  }

  List<LoanPaymentModel> getPayments(String loanId) {
    return _repository.getPayments(loanId);
  }

  Future<void> addMoreToLoan({
    required LoanModel loan,
    required double additionalAmount,
    required String accountId,
    String? note,
  }) async {
    final isLent = loan.type == LoanType.lent;
    
    await _repository.addMore(
      loanId: loan.id,
      additionalAmount: additionalAmount,
      accountId: accountId,
    );

    if (Get.isRegistered<TransactionController>()) {
      final transactionController = Get.find<TransactionController>();
      
      final transactionNote = isLent
          ? 'Extra lending to ${loan.personName}${note != null ? ' - $note' : ''}'
          : 'Extra borrow from ${loan.personName}${note != null ? ' - $note' : ''}';
      
      await transactionController.addTransaction(
        accountId: accountId,
        type: isLent ? TransactionType.expense : TransactionType.income,
        amount: additionalAmount,
        categoryId: isLent ? _lendCategoryId : _borrowCategoryId,
        note: transactionNote,
        date: DateTime.now(),
      );
    }

    loadLoans();
    _refreshAccountBalance(accountId);
  }
}
