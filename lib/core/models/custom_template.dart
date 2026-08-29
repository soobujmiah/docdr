import 'dart:math' as math;

enum DocDrElementType { text, multilineText, date, serial, image, photo, signature, checkbox, qrCode, barcode, line, rectangle, ellipse }
enum DocDrBackgroundType { pdf, image, blank }
enum DocDrTextAlignment { left, center, right, justify }

extension DocDrElementTypeX on DocDrElementType {
  bool get acceptsData => !{DocDrElementType.line, DocDrElementType.rectangle, DocDrElementType.ellipse}.contains(this);
  bool get isTextLike => {DocDrElementType.text, DocDrElementType.multilineText, DocDrElementType.date, DocDrElementType.serial}.contains(this);
  bool get isImageLike => {DocDrElementType.image, DocDrElementType.photo, DocDrElementType.signature}.contains(this);
}

class DocDrElement {
  String id, keyName, label, defaultValue, pattern, fontFamily, fontPath, assetPath, serialPrefix, serialSuffix;
  DocDrElementType type;
  double x, y, width, height, rotation, fontSize, minFontSize, opacity, borderWidth;
  bool locked, hidden, required, bold, italic, underline, autoFit;
  int colorArgb, borderColorArgb, fillColorArgb, serialDigits, serialStart, serialIncrement;
  DocDrTextAlignment alignment;

  DocDrElement({required this.id, required this.type, required this.keyName, required this.label, this.defaultValue='', this.pattern='', this.x=.2, this.y=.2, this.width=.4, this.height=.07, this.rotation=0, this.locked=false, this.hidden=false, this.required=false, this.fontFamily='sans', this.fontPath='', this.fontSize=14, this.minFontSize=7, this.colorArgb=0xFF000000, this.opacity=1, this.bold=false, this.italic=false, this.underline=false, this.autoFit=true, this.alignment=DocDrTextAlignment.left, this.borderColorArgb=0xFF000000, this.fillColorArgb=0x00FFFFFF, this.borderWidth=1, this.assetPath='', this.serialPrefix='SL- ', this.serialSuffix='', this.serialDigits=4, this.serialStart=1, this.serialIncrement=1});

  String resolveValue(Map<String,String> data, {int batchIndex=0}) {
    var value=(data[keyName]??'').trim();
    if(type==DocDrElementType.serial){if(value.isEmpty)value=(serialStart+batchIndex*serialIncrement).toString();final n=int.tryParse(value);if(n!=null)value=n.toString().padLeft(serialDigits,'0');return '$serialPrefix$value$serialSuffix';}
    if(type==DocDrElementType.date&&value.isEmpty){final n=DateTime.now();value='${n.day.toString().padLeft(2,'0')}/${n.month.toString().padLeft(2,'0')}/${n.year}';}
    value=value.isEmpty?defaultValue:value;
    return pattern.isEmpty?value:interpolate(pattern,{...data,keyName:value});
  }
  static String interpolate(String source,Map<String,String> data)=>source.replaceAllMapped(RegExp(r'\{([A-Za-z0-9_]+)\}'),(m)=>data[m.group(1)]??m.group(0)!);
  void clampGeometry(){width=width.clamp(.01,1).toDouble();height=height.clamp(.005,1).toDouble();x=x.clamp(0,math.max(0,1-width)).toDouble();y=y.clamp(0,math.max(0,1-height)).toDouble();opacity=opacity.clamp(0,1).toDouble();fontSize=fontSize.clamp(4,200).toDouble();minFontSize=minFontSize.clamp(4,fontSize).toDouble();serialDigits=serialDigits.clamp(1,12).toInt();}
  Map<String,dynamic> toJson()=>{'id':id,'type':type.name,'keyName':keyName,'label':label,'defaultValue':defaultValue,'pattern':pattern,'x':x,'y':y,'width':width,'height':height,'rotation':rotation,'locked':locked,'hidden':hidden,'required':required,'fontFamily':fontFamily,'fontPath':fontPath,'fontSize':fontSize,'minFontSize':minFontSize,'colorArgb':colorArgb,'opacity':opacity,'bold':bold,'italic':italic,'underline':underline,'autoFit':autoFit,'alignment':alignment.name,'borderColorArgb':borderColorArgb,'fillColorArgb':fillColorArgb,'borderWidth':borderWidth,'assetPath':assetPath,'serialPrefix':serialPrefix,'serialSuffix':serialSuffix,'serialDigits':serialDigits,'serialStart':serialStart,'serialIncrement':serialIncrement};
  factory DocDrElement.fromJson(Map<String,dynamic> j){T ev<T extends Enum>(List<T> v,Object? r,T f)=>v.firstWhere((x)=>x.name==r?.toString(),orElse:()=>f);double d(String k,double f)=>(j[k] as num?)?.toDouble()??f;int i(String k,int f)=>(j[k] as num?)?.toInt()??f;bool b(String k,bool f)=>j[k] is bool?j[k] as bool:f;String s(String k,String f)=>j[k]?.toString()??f;final e=DocDrElement(id:s('id',DateTime.now().microsecondsSinceEpoch.toString()),type:ev(DocDrElementType.values,j['type'],DocDrElementType.text),keyName:s('keyName','field'),label:s('label','Field'),defaultValue:s('defaultValue',''),pattern:s('pattern',''),x:d('x',.2),y:d('y',.2),width:d('width',.4),height:d('height',.07),rotation:d('rotation',0),locked:b('locked',false),hidden:b('hidden',false),required:b('required',false),fontFamily:s('fontFamily','sans'),fontPath:s('fontPath',''),fontSize:d('fontSize',14),minFontSize:d('minFontSize',7),colorArgb:i('colorArgb',0xFF000000),opacity:d('opacity',1),bold:b('bold',false),italic:b('italic',false),underline:b('underline',false),autoFit:b('autoFit',true),alignment:ev(DocDrTextAlignment.values,j['alignment'],DocDrTextAlignment.left),borderColorArgb:i('borderColorArgb',0xFF000000),fillColorArgb:i('fillColorArgb',0x00FFFFFF),borderWidth:d('borderWidth',1),assetPath:s('assetPath',''),serialPrefix:s('serialPrefix','SL- '),serialSuffix:s('serialSuffix',''),serialDigits:i('serialDigits',4),serialStart:i('serialStart',1),serialIncrement:i('serialIncrement',1));e.clampGeometry();return e;}
}

class DocDrPage {
  String id, backgroundPath, previewPath; DocDrBackgroundType backgroundType; int sourcePageIndex; double widthPoints,heightPoints,backgroundOpacity; List<DocDrElement> elements; bool hideBackground,hideOriginalText;
  DocDrPage({required this.id,required this.backgroundType,this.backgroundPath='',this.previewPath='',this.sourcePageIndex=0,this.widthPoints=595.28,this.heightPoints=841.89,List<DocDrElement>? elements,this.hideBackground=false,this.hideOriginalText=false,this.backgroundOpacity=1}):elements=elements??[];
  Map<String,dynamic> toJson()=>{'id':id,'backgroundType':backgroundType.name,'backgroundPath':backgroundPath,'previewPath':previewPath,'sourcePageIndex':sourcePageIndex,'widthPoints':widthPoints,'heightPoints':heightPoints,'elements':elements.map((e)=>e.toJson()).toList(),'hideBackground':hideBackground,'hideOriginalText':hideOriginalText,'backgroundOpacity':backgroundOpacity};
  factory DocDrPage.fromJson(Map<String,dynamic> j){final bt=DocDrBackgroundType.values.firstWhere((v)=>v.name==j['backgroundType'],orElse:()=>DocDrBackgroundType.blank);return DocDrPage(id:j['id']?.toString()??DateTime.now().microsecondsSinceEpoch.toString(),backgroundType:bt,backgroundPath:j['backgroundPath']?.toString()??'',previewPath:j['previewPath']?.toString()??'',sourcePageIndex:(j['sourcePageIndex'] as num?)?.toInt()??0,widthPoints:(j['widthPoints'] as num?)?.toDouble()??595.28,heightPoints:(j['heightPoints'] as num?)?.toDouble()??841.89,elements:((j['elements'] as List?)??const[]).map((e)=>DocDrElement.fromJson(Map<String,dynamic>.from(e as Map))).toList(),hideBackground:j['hideBackground'] is bool?j['hideBackground'] as bool:false,hideOriginalText:j['hideOriginalText'] is bool?j['hideOriginalText'] as bool:false,backgroundOpacity:(j['backgroundOpacity'] as num?)?.toDouble()??1);}
}

class DocDrTemplate {
  static const schemaVersion=2; String id,name,description,basePath; DateTime createdAt,updatedAt; List<DocDrPage> pages; double gridStep; bool snapToGrid;
  DocDrTemplate({required this.id,required this.name,this.description='',required this.createdAt,required this.updatedAt,required this.pages,this.gridStep=.025,this.snapToGrid=true,this.basePath=''});
  Iterable<DocDrElement> get allElements sync*{for(final p in pages)yield* p.elements;}
  List<DocDrElement> get dataFields{final seen=<String>{};return allElements.where((e)=>e.type.acceptsData&&e.keyName.isNotEmpty&&seen.add(e.keyName)).toList();}
  Map<String,dynamic> toJson()=>{'schemaVersion':schemaVersion,'id':id,'name':name,'description':description,'createdAt':createdAt.toIso8601String(),'updatedAt':updatedAt.toIso8601String(),'pages':pages.map((p)=>p.toJson()).toList(),'gridStep':gridStep,'snapToGrid':snapToGrid};
  factory DocDrTemplate.fromJson(Map<String,dynamic> j)=>DocDrTemplate(id:j['id']?.toString()??DateTime.now().microsecondsSinceEpoch.toString(),name:j['name']?.toString()??'Untitled',description:j['description']?.toString()??'',createdAt:DateTime.tryParse(j['createdAt']?.toString()??'')??DateTime.now(),updatedAt:DateTime.tryParse(j['updatedAt']?.toString()??'')??DateTime.now(),pages:((j['pages'] as List?)??const[]).map((p)=>DocDrPage.fromJson(Map<String,dynamic>.from(p as Map))).toList(),gridStep:(j['gridStep'] as num?)?.toDouble()??.025,snapToGrid:j['snapToGrid'] is bool?j['snapToGrid'] as bool:true);
}
