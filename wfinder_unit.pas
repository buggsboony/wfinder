unit wfinder_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  process;

type

  { TForm1 }

  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    IdleTimer1: TIdleTimer;
    ListBox1: TListBox;
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox1Enter(Sender: TObject);
    procedure ComboBox1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ComboBox1Select(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormPaint(Sender: TObject);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1Enter(Sender: TObject);
    procedure ListBox1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
      );
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private

  public

  end;

var
  Form1: TForm1;
  wmList,   windowNames  , windowIds : TStringList;
  lbIndexes:TStringList;
  hprocess: TProcess;

implementation

{$R *.lfm}

{ TForm1 }

procedure wmctrl();
var
wait:boolean=false;
begin
wmList:=TStringList.Create; //... a try...finally block would be nice to make sure
hProcess := TProcess.Create(nil);
hProcess.Executable := 'bash';
// On Linux/Unix/FreeBSD/mmeters on the command line:
 hprocess.Parameters.Add('-c');
 // Here we pipe the password to the sudo command which then executes fdisk -l:
 hprocess.Parameters.add(' wmctrl -l');
//hprocess.Parameters.add('wmctrl -l > /home/boony/wfinder.txt');
//hProcess.Options := hProcess.Options + [poWaitOnExit, poUsePipes];//wait
hProcess.Options := hProcess.Options + [poUsePipes];//wait
//   acOS, we need specify full path to our executable:
// Now run:
hProcess.Execute;
// Now we add all the para
if(wait)then
begin
// hProcess should have now run the external executable (because we use poWaitOnExit).
// Now you can process the process output (standard output and standard error), eg:
  wmList.Add('stdout:');
  wmList.LoadFromStream(hprocess.Output);
  //wmList.Add('stderr:');
 // wmList.LoadFromStream(hProcess.Stderr);
// Show output on screen:
ShowMessage(wmList.Text);
// Clean up to avoid memory leaks:
hProcess.Free;
wmList.Free;
end;

//showMessage('Terminé, j''attendsa pas, je suis un rebelle ');

end;    //Wmctrl()


  
procedure wmctrlSwitch(wname:AnsiString);
var
wait:boolean=false;
begin
wmList:=TStringList.Create; //... a try...finally block would be nice to make sure
hProcess := TProcess.Create(nil);
hProcess.Executable := 'bash';
// On Linux/Unix/FreeBSD/mmeters on the command line:
 hprocess.Parameters.Add('-c');
 // Here we pipe the password to the sudo command which then executes fdisk -l:
 hprocess.Parameters.add(' wmctrl -a '+wname);
//hprocess.Parameters.add('wmctrl -l > /home/boony/wfinder.txt');
//hProcess.Options := hProcess.Options + [poWaitOnExit, poUsePipes];//wait
hProcess.Options := hProcess.Options + [poUsePipes];//wait
//   acOS, we need specify full path to our executable:
// Now run:
hProcess.Execute;
// Now we add all the para
if(wait)then
begin
// hProcess should have now run the external executable (because we use poWaitOnExit).
// Now you can process the process output (standard output and standard error), eg:
  wmList.Add('stdout:');
  wmList.LoadFromStream(hprocess.Output);
  //wmList.Add('stderr:');
 // wmList.LoadFromStream(hProcess.Stderr);
// Show output on screen:
ShowMessage('done');
// Clean up to avoid memory leaks:
hProcess.Free;
wmList.Free;
end;

//showMessage('Terminé, j''attendsa pas, je suis un rebelle ');

end;    //Wmctrl()
//PArser quelque chose comme ca :
//0x0c400007  0 atuf ~ : bash — Konsole
//0x0a400031  1 atuf Getting value from a list box - Embarcadero: Delphi - Tek-Tips - Google Chrome
procedure parseWmList(wmList:TStringList);
var i,j,csteStart:integer;
slParse:TstringList;
line : AnsiString;
swid,si,shostname, rest:AnsiString;
begin
     csteStart:=0;
     slParse:=TStringList.Create;
    slparse.Delimiter:=' ';

  windowNames := TStringList.Create ;
  windowIds := TStringList.Create;

     for i:=0 to wmList.Count-1 do
     begin
       line := wmList[i];

        slParse.DelimitedText:=line;



         for j:=0 to slparse.count-1 do
          begin
            if(j=0) then
            begin
                 swid:=slParse[j];
            end;
            if(j=1) then
             begin
                  si:=slParse[j];
             end;
            if(j=2) then
             begin
                  shostname:=slParse[j];        //Attention Hostane ne doit pas contenir d'espaces !
                  //récup le reeste :
                  if(csteStart=0)then
                  begin
                    csteStart:=line.IndexOf(shostname)+ length(shostname)+1;
                  end;
                  rest :=  trim( copy(line, csteStart, length(line) )  );
                  windowNames.Add(rest);
                  windowIds.Add(swid);
//                        showMessage((rest));
                  break;
             end;

            //ShowMessage('*'+slParse[j]+'*');
          end;



       //break;
     end;

end; //parseWmList

procedure loadItems(form1:TForm1);
begin
  //lbIndexes:=TStringList.Create;
      if(hprocess <> nil)  then
      begin
        // hProcess should have now run the external executable (because we use poWaitOnExit).
        // Now you can process the process output (standard output and standard error), eg:
          wmList.Add('stdout:');
          wmList.LoadFromStream(hprocess.Output);
          //wmList.Add('stderr:');
         // wmList.LoadFromStream(hProcess.Stderr);
        // Show output on screen:
//        ShowMessage(wmList.Text);
          parseWmList(wmList);
          form1.combobox1.Items:= windowNames;
          form1.ListBox1.Items := windowNames;

        // Clean up to avoid memory leaks:
        hProcess.Free;
            hprocess:=nil;
      end;
end;  //loadItems

//switch Window then close self
procedure switchWindow(form1:TForm1;text:ansistring);
var wid:ansistring;
index:integer;
begin
  if(form1.ListBox1.items.count>0) then
  begin
        index:= StrToInt(  lbIndexes[0] );//Le premier
         wid := windowIds[index];
//        ShowMessage( 'selected index: wid= ' +  wid );
//      showMessage( form1.combobox1.text +   inttostr(  form1.ListBox1.items.count) );
        wmctrlSwitch(text);
  end;

end; //switchWindow

procedure fillLbIndexes(form1:TForm1);
var i:integer;
begin
     for i:=0 to form1.ComboBox1.Items.count -1 do
           begin

               lbIndexes.Add( IntToStr(i) );
           end;
end;

function escExit(form1:TForm1; key:Word):boolean;
begin
  if key=27 then
  begin
       Result:=true;
    Form1.Close; //Close on ESC key
  end;
     result:=false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
     wmctrl();
     lbIndexes:=TStringList.Create;
end;

procedure TForm1.ComboBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if(not escExit(form1,key) ) then
  begin
     //on first type load items
     //loadItems(combobox1);

     if key=13 then // on Enter key
     begin
       switchWindow(form1, ComboBox1.Text);
     end;
  end;
end;

procedure TForm1.ComboBox1Select(Sender: TObject);
begin
  switchWindow(form1,ComboBox1.Text);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var i:integer;
  var str:AnsiString;
begin
  ListBox1.Clear;
  lbIndexes.clear;
  if ComboBox1.Text='' then
  begin
      //Vide => all
      ListBox1.Items:=ComboBox1.Items;
  end else
  begin
  //Filter search while typing
           for i:=0 to ComboBox1.Items.count -1 do
           begin
               str:= ComboBox1.Items[i];
                   if( str.ToLower().Contains(LowerCase(ComboBox1.Text) ))then
                   begin
                         //memoriz combo.index;
                          lbIndexes.Add( IntToStr(i) );
                          ListBox1.Items.Add(str);
                   end;
           end;
  end;
end;

procedure TForm1.ComboBox1Enter(Sender: TObject);
begin

end;

procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
  escExit(form1,key);
end;

procedure TForm1.FormPaint(Sender: TObject);
begin


end;

procedure TForm1.IdleTimer1Timer(Sender: TObject);
begin
  loadItems(form1);
  IdleTimer1.Enabled:=false;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin

end;

procedure TForm1.ListBox1Enter(Sender: TObject);
begin
//showMessage('on enter');  ListBox1.ItemIndex:=-1;
end;

procedure TForm1.ListBox1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  escExit(form1,key);
end;

procedure TForm1.ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
     i,index: integer;
     Selected,wid: string;
 begin
     if ListBox1.ItemIndex = -1 then
       Exit;
     Selected := ListBox1.Items[ListBox1.ItemIndex];
   {  for    i:=0 to lbIndexes.Count-1 do
     begin
         s:= lbIndexes[0];
         ShowMessage( inttostr(i)+':'+ lbIndexes[i] );
     end;
     }
     if( lbIndexes.Count = 0)then
     begin
        fillLbIndexes(form1);
     end;
       //wid:= lbIndexes[0]; ShowMessage('idnex str'+wid);
       //index := 0 ; //StrToInt( form1.ListBox1.Selected[0]  );
       //wid:= windowIds[index];
//       showMessage(form1.ListBox1.GetSelectedText() );
       switchWindow(form1, ListBox1.GetSelectedText() );
     //ShowMessage(Selected+' '+ IntToStr( ListBox1.ItemIndex)+' '+ s+' '+  inttostr( lbIndexes.Count ) );
 end;

end.

