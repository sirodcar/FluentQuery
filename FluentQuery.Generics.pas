unit FluentQuery.Generics;

interface
uses
  FluentQuery.Core.Types,
  System.SysUtils,
  System.Generics.Collections,
  FluentQuery.Core.EnumerationStrategies,
  FluentQuery.Core.Enumerators;

type
  IUnboundQueryEnumerator<T> = interface;

  IBoundQueryEnumerator<T> = interface(IBaseQueryEnumerator<T>)
    function GetEnumerator: IBoundQueryEnumerator<T>;
    // common operations
    function First : IBoundQueryEnumerator<T>;
    function Skip(Count : Integer): IBoundQueryEnumerator<T>;
    function SkipWhile(Predicate : TPredicate<T>) : IBoundQueryEnumerator<T>; overload;
    function SkipWhile(UnboundQuery : IUnboundQueryEnumerator<T>) : IBoundQueryEnumerator<T>; overload;
    function Take(Count : Integer): IBoundQueryEnumerator<T>;
    function TakeWhile(Predicate : TPredicate<T>): IBoundQueryEnumerator<T>; overload;
    function TakeWhile(UnboundQuery : IUnboundQueryEnumerator<T>): IBoundQueryEnumerator<T>; overload;
    function Where(Predicate : TPredicate<T>) : IBoundQueryEnumerator<T>;
    function WhereNot(UnboundQuery : IUnboundQueryEnumerator<T>) : IBoundQueryEnumerator<T>; overload;
    function WhereNot(Predicate : TPredicate<T>) : IBoundQueryEnumerator<T>; overload;
    // terminating operations
    function ToTList : TList<T>;
//    function ToTObjectList : TObjectList<T>;
  end;

  IUnboundQueryEnumerator<T> = interface(IBaseQueryEnumerator<T>)
    function GetEnumerator: IUnboundQueryEnumerator<T>;
    // common operations
    function First : IUnboundQueryEnumerator<T>;
    function From(Container : TEnumerable<T>) : IBoundQueryEnumerator<T>;
    function Skip(Count : Integer): IUnboundQueryEnumerator<T>;
    function SkipWhile(Predicate : TPredicate<T>) : IUnboundQueryEnumerator<T>; overload;
    function SkipWhile(UnboundQuery : IUnboundQueryEnumerator<T>) : IUnboundQueryEnumerator<T>; overload;
    function Take(Count : Integer): IUnboundQueryEnumerator<T>;
    function TakeWhile(Predicate : TPredicate<T>): IUnboundQueryEnumerator<T>; overload;
    function TakeWhile(UnboundQuery : IUnboundQueryEnumerator<T>): IUnboundQueryEnumerator<T>; overload;
    function Where(Predicate : TPredicate<T>) : IUnboundQueryEnumerator<T>;
    function WhereNot(UnboundQuery : IUnboundQueryEnumerator<T>) : IUnboundQueryEnumerator<T>; overload;
    function WhereNot(Predicate : TPredicate<T>) : IUnboundQueryEnumerator<T>; overload;
    // terminating operations
    function Predicate : TPredicate<T>;
  end;

  TQueryEnumerator<T> = class(TBaseQueryEnumerator<T>,
                              IBoundQueryEnumerator<T>,
                              IUnboundQueryEnumerator<T>,
                              IBaseQueryEnumerator<T>,
                              IMinimalEnumerator<T>)
  protected
    type
      TQueryEnumeratorImpl<TReturnType : IBaseQueryEnumerator<T>> = class
      private
        FQuery : TQueryEnumerator<T>;
      public
        constructor Create(Query : TQueryEnumerator<T>); virtual;
        function GetEnumerator: TReturnType;
        function First : TReturnType;
        function From(Container : TEnumerable<T>) : IBoundQueryEnumerator<T>;
        function Skip(Count : Integer): TReturnType;
        function SkipWhile(Predicate : TPredicate<T>) : TReturnType; overload;
        function SkipWhile(UnboundQuery : IUnboundQueryEnumerator<T>) : TReturnType; overload;
        function Take(Count : Integer): TReturnType;
        function TakeWhile(Predicate : TPredicate<T>): TReturnType; overload;
        function TakeWhile(UnboundQuery : IUnboundQueryEnumerator<T>): TReturnType; overload;
        function Where(Predicate : TPredicate<T>) : TReturnType;
        function WhereNot(UnboundQuery : IUnboundQueryEnumerator<T>) : TReturnType; overload;
        function WhereNot(Predicate : TPredicate<T>) : TReturnType; overload;
        function Predicate : TPredicate<T>;
        function ToTList : TList<T>;
//        function ToTObjectList(AOwnsObjects: Boolean = True) : TObjectList<T>;
      end;
  protected
    FBoundQueryEnumerator : TQueryEnumeratorImpl<IBoundQueryEnumerator<T>>;
    FUnboundQueryEnumerator : TQueryEnumeratorImpl<IUnboundQueryEnumerator<T>>;
  public
    constructor Create(EnumerationStrategy : TEnumerationStrategy<T>;
                       UpstreamQuery : IBaseQueryEnumerator<T> = nil;
                       SourceData : IMinimalEnumerator<T> = nil); override;
    destructor Destroy; override;
    property BoundQueryEnumerator : TQueryEnumeratorImpl<IBoundQueryEnumerator<T>>
                                       read FBoundQueryEnumerator implements IBoundQueryEnumerator<T>;
    property UnboundQueryEnumerator : TQueryEnumeratorImpl<IUnboundQueryEnumerator<T>>
                                       read FUnboundQueryEnumerator implements IUnboundQueryEnumerator<T>;
  end;


  Query = class
  public
    class function Select<T> : IUnboundQueryEnumerator<T>;
  end;

implementation

{ Query }

class function Query.Select<T>: IUnboundQueryEnumerator<T>;
begin
  Result := TQueryEnumerator<T>.Create(TEnumerationStrategy<T>.Create);
end;



{ TQueryEnumerator<T> }

constructor TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.Create(
  Query: TQueryEnumerator<T>);
begin
  FQuery := Query;
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.First: TReturnType;
begin
  Result := TQueryEnumerator<T>.Create(TTakeWhileEnumerationStrategy<T>.Create(TPredicateFactory<T>.LessThanOrEqualTo(1)),
                                       IBaseQueryEnumerator<T>(FQuery));
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.From(
  Container: TEnumerable<T>): IBoundQueryEnumerator<T>;
var
  EnumeratorWrapper : IMinimalEnumerator<T>;
begin
  EnumeratorWrapper := TGenericEnumeratorAdapter<T>.Create(Container.GetEnumerator) as IMinimalEnumerator<T>;
  Result := TQueryEnumerator<T>.Create(TEnumerationStrategy<T>.Create,
                                       IBaseQueryEnumerator<T>(FQuery),
                                       EnumeratorWrapper);
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.GetEnumerator: TReturnType;
begin
  Result := FQuery;
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.Predicate: TPredicate<T>;
begin
  Result := TPredicateFactory<T>.QuerySingleValue(FQuery);
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.WhereNot(
  UnboundQuery: IUnboundQueryEnumerator<T>): TReturnType;
begin
  Result := WhereNot(UnboundQuery.Predicate);
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.Skip(Count: Integer): TReturnType;
begin
  Result := TQueryEnumerator<T>.Create(TSkipWhileEnumerationStrategy<T>.Create(TPredicateFactory<T>.LessThanOrEqualTo(Count)),
                                       IBaseQueryEnumerator<T>(FQuery));
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.SkipWhile(
  UnboundQuery: IUnboundQueryEnumerator<T>): TReturnType;
begin
  Result := SkipWhile(UnboundQuery.Predicate);
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.SkipWhile(
  Predicate: TPredicate<T>): TReturnType;
begin
  Result := TQueryEnumerator<T>.Create(TSkipWhileEnumerationStrategy<T>.Create(Predicate),
                                       IBaseQueryEnumerator<T>(FQuery));
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.Take(Count: Integer): TReturnType;
begin
  Result := TQueryEnumerator<T>.Create(TTakeWhileEnumerationStrategy<T>.Create(TPredicateFactory<T>.LessThanOrEqualTo(Count)),
                                       IBaseQueryEnumerator<T>(FQuery));
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.TakeWhile(
  UnboundQuery: IUnboundQueryEnumerator<T>): TReturnType;
begin
  Result := TakeWhile(UnboundQuery.Predicate);
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.TakeWhile(
  Predicate: TPredicate<T>): TReturnType;
begin
  Result := TQueryEnumerator<T>.Create(TTakeWhileEnumerationStrategy<T>.Create(Predicate),
                                       IBaseQueryEnumerator<T>(FQuery));
end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.ToTList: TList<T>;
var
  LList : TList<T>;
  Item : T;
begin
  LList := TList<T>.Create;

  while FQuery.MoveNext do
    LList.Add(FQuery.GetCurrent);

  Result := LList;
end;

//function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.ToTObjectList(AOwnsObjects: Boolean = True): TObjectList<T>;
//var
//  LObjectList : TObjectList<T>;
//  Item : T;
//begin
//  LObjectList := TObjectList<T>.Create(AOwnsObjects);
//
//  while FQuery.MoveNext do
//    LObjectList.Add(FQuery.GetCurrent);
//
//  Result := LObjectList;
//end;

function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.Where(
  Predicate: TPredicate<T>): TReturnType;
begin
  Result := TQueryEnumerator<T>.Create(TWhereEnumerationStrategy<T>.Create(Predicate),
                                       IBaseQueryEnumerator<T>(FQuery));
end;


function TQueryEnumerator<T>.TQueryEnumeratorImpl<TReturnType>.WhereNot(
  Predicate: TPredicate<T>): TReturnType;
begin
  Result := TQueryEnumerator<T>.Create(TWhereNotEnumerationStrategy<T>.Create(Predicate),
                                          IBaseQueryEnumerator<T>(FQuery));
end;

{ TQueryEnumerator<T> }

constructor TQueryEnumerator<T>.Create(
  EnumerationStrategy: TEnumerationStrategy<T>;
  UpstreamQuery: IBaseQueryEnumerator<T>; SourceData: IMinimalEnumerator<T>);
begin
  inherited Create(EnumerationStrategy, UpstreamQuery, SourceData);
  FBoundQueryEnumerator := TQueryEnumeratorImpl<IBoundQueryEnumerator<T>>.Create(self);
  FUnboundQueryEnumerator := TQueryEnumeratorImpl<IUnboundQueryEnumerator<T>>.Create(self);
end;

destructor TQueryEnumerator<T>.Destroy;
begin
  FBoundQueryEnumerator.Free;
  FUnboundQueryEnumerator.Free;
  inherited;
end;


end.
