unit SocketErrors;

interface

uses SysUtils;

   function SocketErr(Err: integer): string;


implementation

uses WinSock;


function SocketErr(Err: integer): string;
var
   s : string;
begin
   case Err of
      WSAEINTR                : s := 'EINTR';
      WSAEBADF                : s := 'EBADF';
      WSAEACCES               : s := 'EACCES';
      WSAEFAULT               : s := 'EFAULT';
      WSAEINVAL               : s := 'EINVAL';
      WSAEMFILE               : s := 'EMFILE';
      WSAEWOULDBLOCK          : s := 'EWOULDBLOCK';
      WSAEINPROGRESS          : s := 'EINPROGRESS';
      WSAEALREADY             : s := 'EALREADY';
      WSAENOTSOCK             : s := 'ENOTSOCK';
      WSAEDESTADDRREQ         : s := 'EDESTADDRREQ';
      WSAEMSGSIZE             : s := 'EMSGSIZE';
      WSAEPROTOTYPE           : s := 'EPROTOTYPE';
      WSAENOPROTOOPT          : s := 'ENOPROTOOPT';
      WSAEPROTONOSUPPORT      : s := 'EPROTONOSUPPORT';
      WSAESOCKTNOSUPPORT      : s := 'ESOCKTNOSUPPORT';
      WSAEOPNOTSUPP           : s := 'EOPNOTSUPP';
      WSAEPFNOSUPPORT         : s := 'EPFNOSUPPORT';
      WSAEAFNOSUPPORT         : s := 'EAFNOSUPPORT';
      WSAEADDRINUSE           : s := 'EADDRINUSE';
      WSAEADDRNOTAVAIL        : s := 'EADDRNOTAVAIL';
      WSAENETDOWN             : s := 'ENETDOWN';
      WSAENETUNREACH          : s := 'ENETUNREACH';
      WSAENETRESET            : s := 'ENETRESET';
      WSAECONNABORTED         : s := 'ECONNABORTED';
      WSAECONNRESET           : s := 'ECONNRESET';
      WSAENOBUFS              : s := 'ENOBUFS';
      WSAEISCONN              : s := 'EISCONN';
      WSAENOTCONN             : s := 'ENOTCONN';
      WSAESHUTDOWN            : s := 'ESHUTDOWN';
      WSAETOOMANYREFS         : s := 'ETOOMANYREFS';
      WSAETIMEDOUT            : s := 'ETIMEDOUT';
      WSAECONNREFUSED         : s := 'ECONNREFUSED';
      WSAELOOP                : s := 'ELOOP';
      WSAENAMETOOLONG         : s := 'ENAMETOOLONG';
      WSAEHOSTDOWN            : s := 'EHOSTDOWN';
      WSAEHOSTUNREACH         : s := 'EHOSTUNREACH';
      WSAENOTEMPTY            : s := 'ENOTEMPTY';
      WSAEPROCLIM             : s := 'EPROCLIM';
      WSAEUSERS               : s := 'EUSERS';
      WSAEDQUOT               : s := 'EDQUOT';
      WSAESTALE               : s := 'ESTALE';
      WSAEREMOTE              : s := 'EREMOTE';
      WSAEDISCON              : s := 'EDISCON';
      WSASYSNOTREADY          : s := 'SYSNOTREADY';
      WSAVERNOTSUPPORTED      : s := 'VERNOTSUPPORTED';
      WSANOTINITIALISED       : s := 'NOTINITIALISED';
      WSAHOST_NOT_FOUND       : s := 'HOST_NOT_FOUND';
      WSATRY_AGAIN            : s := 'TRY_AGAIN';
      WSANO_RECOVERY          : s := 'NO_RECOVERY';
      WSANO_DATA              : s := 'NO_DATA';
      else s := Format('Unknown (%d)', [Err]);
   end;
   Result := 'Windows Sockets - ' + s;
end;

end.

