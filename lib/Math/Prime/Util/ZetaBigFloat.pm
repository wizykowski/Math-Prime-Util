package Math::Prime::Util::ZetaBigFloat;
use strict;
use warnings;

BEGIN {
  $Math::Prime::Util::ZetaBigFloat::AUTHORITY = 'cpan:DANAJ';
  $Math::Prime::Util::ZetaBigFloat::VERSION = '0.50';
}

BEGIN {
  do { require Math::BigInt;  Math::BigInt->import(try=>"GMP,Pari"); }
    unless defined $Math::BigInt::VERSION;
  use Math::BigFloat;
}


# Riemann Zeta($k) for integer $k.
# So many terms and digits are used so we can quickly do bignum R.
my @_Riemann_Zeta_Table = (
  '0.64493406684822643647241516664602518921894990',   # zeta(2) - 1
  '0.20205690315959428539973816151144999076498629',
  '0.082323233711138191516003696541167902774750952',
  '0.036927755143369926331365486457034168057080920',
  '0.017343061984449139714517929790920527901817490',
  '0.0083492773819228268397975498497967595998635606',
  '0.0040773561979443393786852385086524652589607906',
  '0.0020083928260822144178527692324120604856058514',
  '0.00099457512781808533714595890031901700601953156',
  '0.00049418860411946455870228252646993646860643576',
  '0.00024608655330804829863799804773967096041608846',
  '0.00012271334757848914675183652635739571427510590',
  '0.000061248135058704829258545105135333747481696169',
  '0.000030588236307020493551728510645062587627948707',
  '0.000015282259408651871732571487636722023237388990',
  '0.0000076371976378997622736002935630292130882490903',
  '0.0000038172932649998398564616446219397304546972190',
  '0.0000019082127165539389256569577951013532585711448',
  '0.00000095396203387279611315203868344934594379418741',
  '0.00000047693298678780646311671960437304596644669478',
  '0.00000023845050272773299000364818675299493504182178',
  '0.00000011921992596531107306778871888232638725499778',
  '0.000000059608189051259479612440207935801227503918837',
  '0.000000029803503514652280186063705069366011844730920',
  '0.000000014901554828365041234658506630698628864788168',
  '0.0000000074507117898354294919810041706041194547190319',
  '0.0000000037253340247884570548192040184024232328930593',
  '0.0000000018626597235130490064039099454169480616653305',
  '0.00000000093132743241966818287176473502121981356795514',
  '0.00000000046566290650337840729892332512200710626918534',
  '0.00000000023283118336765054920014559759404950248298228',
  '0.00000000011641550172700519775929738354563095165224717',
  '0.000000000058207720879027008892436859891063054173122605',
  '0.000000000029103850444970996869294252278840464106981987',
  '0.000000000014551921891041984235929632245318420983808894',
  '0.0000000000072759598350574810145208690123380592648509256',
  '0.0000000000036379795473786511902372363558732735126460284',
  '0.0000000000018189896503070659475848321007300850305893096',
  '0.00000000000090949478402638892825331183869490875386000099',
  '0.00000000000045474737830421540267991120294885703390452991',
  '0.00000000000022737368458246525152268215779786912138298220',
  '0.00000000000011368684076802278493491048380259064374359028',
  '0.000000000000056843419876275856092771829675240685530571589',
  '0.000000000000028421709768893018554550737049426620743688265',
  '0.000000000000014210854828031606769834307141739537678698606',
  '0.0000000000000071054273952108527128773544799568000227420436',
  '0.0000000000000035527136913371136732984695340593429921456555',
  '0.0000000000000017763568435791203274733490144002795701555086',
  '0.00000000000000088817842109308159030960913863913863256088715',
  '0.00000000000000044408921031438133641977709402681213364596031',
  '0.00000000000000022204460507980419839993200942046539642366543',
  '0.00000000000000011102230251410661337205445699213827024832229',
  '0.000000000000000055511151248454812437237365905094302816723551',
  '0.000000000000000027755575621361241725816324538540697689848904',
  '0.000000000000000013877787809725232762839094906500221907718625',
  '0.0000000000000000069388939045441536974460853262498092748358742',
  '0.0000000000000000034694469521659226247442714961093346219504706',
  '0.0000000000000000017347234760475765720489729699375959074780545',
  '0.00000000000000000086736173801199337283420550673429514879071415',
  '0.00000000000000000043368086900206504874970235659062413612547801',
  '0.00000000000000000021684043449972197850139101683209845761574010',
  '0.00000000000000000010842021724942414063012711165461382589364744',
  '0.000000000000000000054210108624566454109187004043886337150634224',
  '0.000000000000000000027105054312234688319546213119497764318887282',
  '0.000000000000000000013552527156101164581485233996826928328981877',
  '0.0000000000000000000067762635780451890979952987415566862059812586',
  '0.0000000000000000000033881317890207968180857031004508368340311585',
  '0.0000000000000000000016940658945097991654064927471248619403036418',
  '0.00000000000000000000084703294725469983482469926091821675222838642',
  '0.00000000000000000000042351647362728333478622704833579344088109717',
  '0.00000000000000000000021175823681361947318442094398180025869417612',
  '0.00000000000000000000010587911840680233852265001539238398470699902',
  '0.000000000000000000000052939559203398703238139123029185055866375629',
  '0.000000000000000000000026469779601698529611341166842038715592556134',
  '0.000000000000000000000013234889800848990803094510250944989684323826',
  '0.0000000000000000000000066174449004244040673552453323082200147137975',
  '0.0000000000000000000000033087224502121715889469563843144048092764894',
  '0.0000000000000000000000016543612251060756462299236771810488297723589',
  '0.00000000000000000000000082718061255303444036711056167440724040096811',
  '0.00000000000000000000000041359030627651609260093824555081412852575873',
  '0.00000000000000000000000020679515313825767043959679193468950443365312',
  '0.00000000000000000000000010339757656912870993284095591745860911079606',
  '0.000000000000000000000000051698788284564313204101332166355512893608164',
  '0.000000000000000000000000025849394142282142681277617708450222269121159',
  '0.000000000000000000000000012924697071141066700381126118331865309299779',
  '0.0000000000000000000000000064623485355705318034380021611221670660356864',
  '0.0000000000000000000000000032311742677852653861348141180266574173608296',
  '0.0000000000000000000000000016155871338926325212060114057052272720509148',
  '0.00000000000000000000000000080779356694631620331587381863408997398684847',
  '0.00000000000000000000000000040389678347315808256222628129858130379479700',
  '0.00000000000000000000000000020194839173657903491587626465673047518903728',
  '0.00000000000000000000000000010097419586828951533619250700091044144538432',
  '0.000000000000000000000000000050487097934144756960847711725486604360898735',
  '0.000000000000000000000000000025243548967072378244674341937966175648398693',
  '0.000000000000000000000000000012621774483536189043753999660777148710632765',
  '0.0000000000000000000000000000063108872417680944956826093943332037500694712',
  '0.0000000000000000000000000000031554436208840472391098412184847972814371270',
  '0.0000000000000000000000000000015777218104420236166444327830159601782237092',
  '0.00000000000000000000000000000078886090522101180735205378276604136878962534',
  '0.00000000000000000000000000000039443045261050590335263935513575963608141044',
  '0.00000000000000000000000000000019721522630525295156852383215213909988473843',
  '0.000000000000000000000000000000098607613152626475748329967604159218377505181',
  '0.000000000000000000000000000000049303806576313237862187667644776975622245754',
  '0.000000000000000000000000000000024651903288156618927101395103287812527732549',
  '0.000000000000000000000000000000012325951644078309462219884645277065145764150',
  '0.0000000000000000000000000000000061629758220391547306663380205162648609383631',
  '0.0000000000000000000000000000000030814879110195773651853009095507130250105264',
  '0.0000000000000000000000000000000015407439555097886825433610878728841686496904',
  '0.00000000000000000000000000000000077037197775489434125525075496895150086398231',
  '0.00000000000000000000000000000000038518598887744717062214878116197893873445220',
  '0.00000000000000000000000000000000019259299443872358530924885847349054449873362',
  '0.000000000000000000000000000000000096296497219361792654015918534245633717541108',
  '0.000000000000000000000000000000000048148248609680896326805122366289604787579935',
  '0.000000000000000000000000000000000024074124304840448163334948882867065229914248',
  '0.000000000000000000000000000000000012037062152420224081644937008007620275295506',
  '0.0000000000000000000000000000000000060185310762101120408149560261951727031681191',
  '0.0000000000000000000000000000000000030092655381050560204049738538280405431094080',
  '0.0000000000000000000000000000000000015046327690525280102016522071575050028177934',
  '0.00000000000000000000000000000000000075231638452626400510054786365991407868525313',
  '0.00000000000000000000000000000000000037615819226313200255018118519034423181524371',
  '0.00000000000000000000000000000000000018807909613156600127505967704863451341028548',
  '0.000000000000000000000000000000000000094039548065783000637519533342138055875645097',
  '0.000000000000000000000000000000000000047019774032891500318756331610342627662060287',
  '0.000000000000000000000000000000000000023509887016445750159377020784929180405960294',
  '0.000000000000000000000000000000000000011754943508222875079688128719050545728002924',
  '0.0000000000000000000000000000000000000058774717541114375398439371350539247056872356',
  '0.0000000000000000000000000000000000000029387358770557187699219261593698463000750878',
  '0.0000000000000000000000000000000000000014693679385278593849609489436325511324487536',
  '0.00000000000000000000000000000000000000073468396926392969248046975979881822702829326',
  '0.00000000000000000000000000000000000000036734198463196484624023330922692333378216377',
  '0.00000000000000000000000000000000000000018367099231598242312011613105596640698043218',
  '0.000000000000000000000000000000000000000091835496157991211560057891008818116853335663',
  '0.000000000000000000000000000000000000000045917748078995605780028887331354029547708393',
  '0.000000000000000000000000000000000000000022958874039497802890014424274658671814201226',
  '0.000000000000000000000000000000000000000011479437019748901445007205673656554920549667',
  '0.0000000000000000000000000000000000000000057397185098744507225036006822706837980911955',
  '0.0000000000000000000000000000000000000000028698592549372253612517996229494773449843879',
  '0.0000000000000000000000000000000000000000014349296274686126806258995720794504878051247',
  '0.00000000000000000000000000000000000000000071746481373430634031294970624129584900687276',
  '0.00000000000000000000000000000000000000000035873240686715317015647482652117145953820656',
  '0.00000000000000000000000000000000000000000017936620343357658507823740439409357478069335',
  '0.000000000000000000000000000000000000000000089683101716788292539118699241549402394210037',
  '0.000000000000000000000000000000000000000000044841550858394146269559348635608906198392806',
  '0.000000000000000000000000000000000000000000022420775429197073134779673989415854766292332',
  '0.000000000000000000000000000000000000000000011210387714598536567389836885245061272178142',
  '0.0000000000000000000000000000000000000000000056051938572992682836949184061349085990997301',
  '0.0000000000000000000000000000000000000000000028025969286496341418474591909049136205534180',
  '0.0000000000000000000000000000000000000000000014012984643248170709237295913982765839445600',
  '0.00000000000000000000000000000000000000000000070064923216240853546186479434774488319489698',
  '0.00000000000000000000000000000000000000000000035032461608120426773093239672340797200498749',
  '0.00000000000000000000000000000000000000000000017516230804060213386546619821154916280500674',
  '0.000000000000000000000000000000000000000000000087581154020301066932733099055722973670007705',
  '0.000000000000000000000000000000000000000000000043790577010150533466366549511177617590838630',
  '0.000000000000000000000000000000000000000000000021895288505075266733183274750027519047364241',
  '0.000000000000000000000000000000000000000000000010947644252537633366591637373159996274330429',
  '0.0000000000000000000000000000000000000000000000054738221262688166832958186859620770540479841',
  '0.0000000000000000000000000000000000000000000000027369110631344083416479093427750648326515819',
  '0.0000000000000000000000000000000000000000000000013684555315672041708239546713188745182016542',
  '0.00000000000000000000000000000000000000000000000068422776578360208541197733563655129305944821',
  '0.00000000000000000000000000000000000000000000000034211388289180104270598866781064699118259780',
  '0.00000000000000000000000000000000000000000000000017105694144590052135299433390278061047559013',
  '0.000000000000000000000000000000000000000000000000085528470722950260676497166950542676865892145',
  '0.000000000000000000000000000000000000000000000000042764235361475130338248583474988795642311765',
  '0.000000000000000000000000000000000000000000000000021382117680737565169124291737400216890944447',
  '0.000000000000000000000000000000000000000000000000010691058840368782584562145868668714802068411',
  '0.0000000000000000000000000000000000000000000000000053455294201843912922810729343238928532329351',
  '0.0000000000000000000000000000000000000000000000000026727647100921956461405364671584582440160440',
  '0.0000000000000000000000000000000000000000000000000013363823550460978230702682335780663944745475',
  '0.00000000000000000000000000000000000000000000000000066819117752304891153513411678864562139278223',
  '0.00000000000000000000000000000000000000000000000000033409558876152445576756705839419361874822728',
  '0.00000000000000000000000000000000000000000000000000016704779438076222788378352919705374539139236',
  '0.000000000000000000000000000000000000000000000000000083523897190381113941891764598512518034789088',
  '0.000000000000000000000000000000000000000000000000000041761948595190556970945882299251474130425513',
  '0.000000000000000000000000000000000000000000000000000020880974297595278485472941149624142102889746',
  '0.000000000000000000000000000000000000000000000000000010440487148797639242736470574811539397337203',
  '0.0000000000000000000000000000000000000000000000000000052202435743988196213682352874055924806327115',
  '0.0000000000000000000000000000000000000000000000000000026101217871994098106841176437027371676377257',
  '0.0000000000000000000000000000000000000000000000000000013050608935997049053420588218513488929259862',
  '0.00000000000000000000000000000000000000000000000000000065253044679985245267102941092566788283203421',
);
# Convert to BigFloat objects.
@_Riemann_Zeta_Table = map { Math::BigFloat->new($_) } @_Riemann_Zeta_Table;
# for k = 1 .. n :  (1 / (zeta(k+1) * k + k)
# Makes RiemannR run about twice as fast.
my @_Riemann_Zeta_Premult;
my $_Riemann_Zeta_premult_accuracy = 0;

# Select n = 55, good for 46ish digits of accuracy.
my $_Borwein_n = 55;
my @_Borwein_dk = (
  '1',
  '6051',
  '6104451',
  '2462539971',
  '531648934851',
  '71301509476803',
  '6504925195108803',
  '429144511928164803',
  '21392068013887742403',
  '832780518854440804803',
  '25977281563850106233283',
  '662753606729324750201283',
  '14062742362385399866745283',
  '251634235316509414702211523',
  '3841603462178827861104812483',
  '50535961819850087101900022211',
  '577730330374203014014104003011',
  '5782012706584553297863989289411',
  '50984922488525881477588707205571',
  '398333597655022403279683908035011',
  '2770992240330783259897072664469955',
  '17238422988353715312442126057365955',
  '96274027751337344115352100618133955',
  '484350301573059857715727453968687555',
  '2201794236784087151947175826243477955',
  '9068765987529892610841571032285864387',
  '33926582279822401059328069515697217987',
  '115535262182820447663793177744255246787',
  '358877507711760077538925500462137369027',
  '1018683886695854101193095537014797787587',
  '2646951832121008166346437186541363159491',
  '6306464665572570713623910486640730071491',
  '13799752848354341643763498672558481367491',
  '27780237373991939435100856211039992177091',
  '51543378762608611361377523633779417047491',
  '88324588911945720951614452340280439890371',
  '140129110249040241501243929391690331218371',
  '206452706984942815385219764876242498642371',
  '283527707823296964404071683165658912154051',
  '364683602811933600833512164561308162744771',
  '441935796522635816776473230396154031661507',
  '508231717051242054487234759342047053767107',
  '559351463001010719709990637083458540691907',
  '594624787018881191308291683229515933311427',
  '616297424973434835299724300924272199623107',
  '628083443816135918099559567176252011864515',
  '633714604276098212796088600263676671320515',
  '636056734158553360761837806887547188568515',
  '636894970116484676875895417679248215794115',
  '637149280289288581322870186196318041432515',
  '637213397278310656625865036925470191411651',
  '637226467136294189739463288384528579584451',
  '637228536449134002301138291602841035366851',
  '637228775173095037281299181461988671775171',
  '637228793021615488494769154535569803469251',
  '637228793670652595811622608101881844621763',
);
# "An Efficient Algorithm for the Riemann Zeta Function", Borwein, 1991.
# About 1.3n terms are needed for n digits of accuracy.
sub _Recompute_Dk {
  my $nterms = shift;
  $_Borwein_n = $nterms;
  @_Borwein_dk = ();
  my $orig_acc = Math::BigFloat->accuracy();
  Math::BigFloat->accuracy($nterms);
  foreach my $k (0 .. $nterms) {
    my $sum = Math::BigInt->bzero;
    my $num = Math::BigInt->new($nterms-1)->bfac();
    foreach my $i (0 .. $k) {
      my $den = Math::BigInt->new($nterms - $i)->bfac * Math::BigInt->new(2*$i)->bfac;
      $sum += $num->copy->bdiv($den);
      $num->bmul(4 * ($nterms+$i));
    }
    $sum->bmul($nterms);
    $_Borwein_dk[$k] = $sum;
  }
  Math::BigFloat->accuracy($orig_acc);
}

sub RiemannZeta {
  my($ix) = @_;

  my $x = (ref($ix) eq 'Math::BigFloat') ? $ix->copy : Math::BigFloat->new("$ix");
  $x->accuracy($ix->accuracy) if $ix->accuracy;
  my $xdigits = $ix->accuracy() || Math::BigFloat->accuracy() || Math::BigFloat->div_scale();

  if ($x == int($x) && $xdigits <= 44 && (int($x)-2) <= $#_Riemann_Zeta_Table) {
    my $izeta = $_Riemann_Zeta_Table[int($x)-2]->copy;
    $izeta->bround($xdigits);
    return $izeta;
  }

  # Note, this code likely will not work correctly without fixes for RTs:
  #
  #   43692 : blog and others broken
  #   43460 : exp and powers broken
  #
  # E.g:
  #   my $n = Math::BigFloat->new(11); $n->accuracy(64); say $n**1.1;  # 13.98
  #   my $n = Math::BigFloat->new(11); $n->accuracy(67); say $n**1.1;  # 29.98
  #
  # There is a hack that tries to work around some of the problem, but it
  # can't cover everything and it slows things down a lot.  There just isn't
  # any way to do this if the basic math operations don't work right.

  my $orig_acc = Math::BigFloat->accuracy();
  my $extra_acc = 5;
  if ($x > 15 && $x <= 50) { $extra_acc = 15; }

  $xdigits += $extra_acc;
  Math::BigFloat->accuracy($xdigits);
  $x->accuracy($xdigits);
  my $zero= $x->copy->bzero;
  my $one = $zero->copy->binc;
  my $two = $one->copy->binc;

  my $tol = ref($x)->new('0.' . '0' x ($xdigits-1) . '1');

  # Note: with bignum on, $d1->bpow($one-$x) doesn't change d1 !

  # This is a hack to turn 6^-40.5 into (6^-(40.5/4))^4.  It helps work around
  # the two RTs listed earlier, though does not completely fix their bugs.
  # It has the downside of making integer arguments very slow.

  my $superx = Math::BigInt->bone;
  my $subx = $x->copy;
  my $intx = int("$x");
  if ($Math::BigFloat::VERSION < 1.9996 || $x != $intx) {
    while ($subx > 1) {
      $superx->blsft(1);
      $subx /= $two;
    }
  }

  if (1 && $x == $intx && $x >= 2 && !($intx & 1) && $intx < 100) {
    # Mathworld equation 63.  How fast this is relative to the others is
    # dependent on the backend library and if we have MPUGMP.
    $x = int("$x");
    my $den = Math::Prime::Util::factorial($x);
    $xdigits -= $extra_acc;
    $extra_acc += length($den);
    $xdigits += $extra_acc;
    $one->accuracy($xdigits); $two->accuracy($xdigits);
    Math::BigFloat->accuracy($xdigits);
    $subx->accuracy($xdigits);  $superx->accuracy($xdigits);
    my $Pix = Math::Prime::Util::Pi($xdigits)->bpow($subx)->bpow($superx);
    my $Bn = Math::Prime::Util::bernreal($x);  $Bn = -$Bn if $Bn < 0;
    my $twox1 = $two->copy->bpow($x-1);
    #my $num = $Pix  *  $Bn  *  $twox1;
    #my $res = $num->bdiv($den)->bdec->bround($xdigits - $extra_acc);
    my $res = $Bn->bdiv($den)->bmul($Pix)->bmul($twox1)->bdec
              ->bround($xdigits-$extra_acc);
    Math::BigFloat->accuracy($orig_acc);
    return $res;
  }

  # Go with the basic formula for large x.
  if (1 && $x >= 50) {
    my $negsubx = $subx->copy->bneg;
    my $sum = $zero->copy;
    my $k = $two->copy->binc;
    while ($k->binc <= 1000) {
      my $term = $k->copy->bpow($negsubx)->bpow($superx);
      $sum += $term;
      last if $term < ($sum*$tol);
    }
    $k = $two+$two;
    $k->bdec(); $sum += $k->copy->bpow($negsubx)->bpow($superx);
    $k->bdec(); $sum += $k->copy->bpow($negsubx)->bpow($superx);
    $sum->bround($xdigits-$extra_acc);
    Math::BigFloat->accuracy($orig_acc);
    return $sum;
  }

  {
    my $dig = int($_Borwein_n / 1.3)+1;
    _Recompute_Dk( int($xdigits * 1.3) + 4 )  if $dig < $xdigits;
  }

  if (ref $_Borwein_dk[0] ne 'Math::BigInt') {
    @_Borwein_dk = map { Math::BigInt->new("$_") } @_Borwein_dk;
  }

  my $n = $_Borwein_n;

  my $d1 = $two ** ($one - $x);
  my $divisor = ($one - $d1) * $_Borwein_dk[$n];
  $divisor->bneg;
  $tol = ($divisor * $tol)->babs();

  my ($sum, $bigk) = ($zero->copy, $one->copy);
  my $negsubx = $subx->copy->bneg;
  foreach my $k (1 .. $n-1) {
    my $den = $bigk->binc()->copy->bpow($negsubx)->bpow($superx);
    my $term = ($k % 2) ? ($_Borwein_dk[$n] - $_Borwein_dk[$k])
                        : ($_Borwein_dk[$k] - $_Borwein_dk[$n]);
    $term = Math::BigFloat->new($term) unless ref($term) eq 'Math::BigFloat';
    $sum += $term * $den;
    last if $term->copy->babs() < $tol;
  }
  $sum += $_Borwein_dk[0] - $_Borwein_dk[$n];
  $sum = $sum->bdiv($divisor);
  $sum->bdec->bround($xdigits-$extra_acc);
  Math::BigFloat->accuracy($orig_acc);
  return $sum;
}

# Riemann R function
sub RiemannR {
  my($x) = @_;

  if (ref($x) eq 'Math::BigInt') {
    my $xacc = $x->accuracy();
    $x = Math::BigFloat->new($x);
    $x->accuracy($xacc) if $xacc;
  }
  $x = Math::BigFloat->new("$x") if ref($x) ne 'Math::BigFloat';
  my $xdigits = $x->accuracy || Math::BigFloat->accuracy() || Math::BigFloat->div_scale();
  my $extra_acc = 1;
  $xdigits += $extra_acc;
  my $orig_acc = Math::BigFloat->accuracy();
  Math::BigFloat->accuracy($xdigits);
  $x->accuracy($xdigits);
  my $tol = $x->copy->bone->brsft($xdigits-1, 10);
  my $sum = $x->copy->bone;

  if ($xdigits <= length($x->copy->as_int->bstr())) {

    for my $k (1 .. 1000) {
      my $mob = Math::Prime::Util::moebius($k);
      next if $mob == 0;
      $mob = Math::BigFloat->new($mob);
      my $term = $mob->bdiv($k) *
                 Math::Prime::Util::LogarithmicIntegral($x->copy->broot($k));
      $sum += $term;
      #warn "k = $k  term = $term  sum = $sum\n";
      last if abs($term) < ($tol * abs($sum));
    }

  } else {

    my ($flogx, $part_term, $fone, $bigk)
    = (log($x), Math::BigFloat->bone, Math::BigFloat->bone, Math::BigInt->bone);

    if ($_Riemann_Zeta_premult_accuracy < $xdigits) {
      @_Riemann_Zeta_Premult = ();
      $_Riemann_Zeta_premult_accuracy = $xdigits;
    }

    for my $k (1 .. 10000) {
      my $zeta_term = $_Riemann_Zeta_Premult[$k-1];
      if (!defined $zeta_term) {
        my $zeta = ($xdigits > 44) ? undef : $_Riemann_Zeta_Table[$k-1];
        if (!defined $zeta) {
          my $kz = $fone->copy->badd($bigk);  # kz is k+1
          if (($k+1) >= 100 && $xdigits <= 40) {
            # For this accuracy level, two terms are more than enough.  Also,
            # we should be able to miss the Math::BigFloat accuracy bug.  If we
            # try to do this for higher accuracy, things will go very bad.
            $zeta = Math::BigFloat->new(3)->bpow(-$kz)
                  + Math::BigFloat->new(2)->bpow(-$kz);
          } else {
            $zeta = Math::Prime::Util::ZetaBigFloat::RiemannZeta( $kz );
          }
        }
        $zeta_term = $fone / ($zeta * $bigk + $bigk);
        $_Riemann_Zeta_Premult[$k-1] = $zeta_term if defined $_Riemann_Zeta_Table[$k-1];
      }
      $part_term *= $flogx / $bigk;
      my $term = $part_term * $zeta_term;
      $sum += $term;
      #warn "k = $k  term = $term  sum = $sum\n";
      last if $term < ($tol*$sum);
      $bigk->binc;
    }

  }
  $sum->bround($xdigits-$extra_acc);
  Math::BigFloat->accuracy($orig_acc);
  return $sum;
}

1;

__END__


# ABSTRACT: Perl Big Float versions of Riemann Zeta and R functions

=pod

=encoding utf8


=head1 NAME

Math::Prime::Util::ZetaBigFloat - Perl Big Float versions of Riemann Zeta and R functions


=head1 VERSION

Version 0.50


=head1 SYNOPSIS

Math::BigFloat versions`of the Riemann Zeta and Riemann R functions.  These
are kept in a separate module because they use a lot of big tables that we'd
prefer to only load if needed.


=head1 DESCRIPTION

Pure Perl implementations of Riemann Zeta and Riemann R using Math::BigFloat.
These functions are used if:

=over 4

=item The input is a BigInt, a BigFloat, or the bignum module has been loaded.

=item The Math::MPFR module is not available.

=back

If you use these functions a lot, I B<highly> recommend you install
L<Math::MPFR>, which the main L<Math::Prime::Util> functions will find.
These give B<much> better performance, and better accuracy.  You can also
use L<Math::Pari> for the Riemann Zeta function.


=head1 FUNCTIONS

=head2 RiemannZeta

  my $z = RiemannZeta($s);

Given a floating point input C<s> where C<s E<gt>= 0.5>, returns the floating
point value of ζ(s)-1, where ζ(s) is the Riemann zeta function.  One is
subtracted to ensure maximum precision for large values of C<s>.  The zeta
function is the sum from k=1 to infinity of C<1 / k^s>

Results are calculated using either Borwein (1991) algorithm 2, or the basic
series.  Full input accuracy is attempted, but there are defects in
Math::BigFloat with high accuracy computations that make this difficult.


=head2 RiemannR

  my $r = RiemannR($x);

Given a positive non-zero floating point input, returns the floating
point value of Riemann's R function.  Riemann's R function gives a very close
approximation to the prime counting function.

Accuracy should be about 35 digits.


=head1 LIMITATIONS

Bugs in Math::BigFloat (RT 43692, RT 77105) cause many problems with this code.
I've attempted to work around them, but it is possible there are cases they
miss.

The accuracy goals (35 digits) are sometimes missed by a digit or two.


=head1 PERFORMANCE

Performance is quite bad.


=head1 SEE ALSO

L<Math::Prime::Util>

L<Math::MPFR>

L<Math::Pari>


=head1 AUTHORS

Dana Jacobsen E<lt>dana@acm.orgE<gt>


=head1 COPYRIGHT

Copyright 2012 by Dana Jacobsen E<lt>dana@acm.orgE<gt>

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
