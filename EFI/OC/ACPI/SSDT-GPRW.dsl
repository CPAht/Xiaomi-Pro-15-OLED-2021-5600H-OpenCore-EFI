/*
 * GPRW wake-source whitelist for macOS (Darwin).
 *
 * Goal: only lid open and power button may wake the machine.
 *
 * Firmware wake map (from patched DSDT _PRW):
 *   GPE 0x08 -> GPP0/GPP1/GPP5/GP17/GP18 + _GPE._L08 notifies PWRB
 *               => power-button wake path, ALLOWED
 *   GPE 0x0D -> GPP2   (XL0D)  => blocked
 *   GPE 0x0E -> GPP4   (XL0E)  => blocked
 *   GPE 0x0F -> GPP3   (XL0F)  => blocked
 *   GPE 0x19 -> GP17 / XHC0 / XHC1 (USB) => blocked
 *   Any other GPE                  => blocked
 *
 * Lid and power button real events use EC GPE 0x03
 * (_Q52/_Q53 lid, _Q78 power button) which does NOT go through GPRW,
 * so they are untouched by this whitelist.
 *
 * Blocking method: forward to original XPRW with sleep-state = Zero.
 * XPRW builds Package {GPE, state} => {GPE, 0} means "cannot wake".
 */
DefinitionBlock ("", "SSDT", 2, "RAPID", "GPRW", 0x00000000)
{
    External (XPRW, MethodObj)    // 2 Arguments

    Method (GPRW, 2, NotSerialized)
    {
        If (_OSI ("Darwin"))
        {
            /* GPE 0x08 carries the power-button wake notify (PWRB). */
            If ((Arg0 == 0x08))
            {
                Return (XPRW (Arg0, Arg1))
            }

            /* Block every other GPE from waking the system. */
            Return (XPRW (Arg0, Zero))
        }

        Return (XPRW (Arg0, Arg1))
    }
}
