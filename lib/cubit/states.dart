abstract class States{}
class InitialState extends States {}
class LoadingState extends States {}
class SuccessState extends States {}
class ErrorState extends States {
  final String error;

  ErrorState(this.error);
}


// logout states
class LogoutLoadingState extends States {}
class LogoutSuccessState extends States {}
class LogoutErrorState extends States {
  final String error;

  LogoutErrorState(this.error);
}

// list states
class ListLoadingState extends States {}
class ListSuccessState extends States {}
class ListErrorState extends States {
  final String error;

  ListErrorState(this.error);
}

// one states
class OneLoadingState extends States {}
class OneSuccessState extends States {}
class OneErrorState extends States {
  final String error;

  OneErrorState(this.error);
}
// delete states
class DeleteLoadingState extends States {}
class DeleteSuccessState extends States {}
class DeleteErrorState extends States {
  final String error;

  DeleteErrorState(this.error);
}

// edit states
class EditLoadingState extends States {}
class EditSuccessState extends States {}
class EditErrorState extends States {
  final String error;

  EditErrorState(this.error);
}


// refresh token states
class RefreshLoadingState extends States {}
class RefreshSuccessState extends States {
  final String token;

  RefreshSuccessState(this.token);
}
class RefreshErrorState extends States {
  final String error;

  RefreshErrorState(this.error);
}

// uplaod photo
class ImageLoadingState extends States {}
class ImageSuccessState extends States {}
class ImageErrorState extends States {}
class RemoveImageState extends States {}

class TaskLoadingState extends States {}
class TaskSuccessState extends States {}
class TaskErrorState extends States {}

class RemoveItemState extends States {}



class NoInternetState extends States {
  final String error;

  NoInternetState(this.error);
}
